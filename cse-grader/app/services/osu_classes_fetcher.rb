require "httparty"
require "time"
require "date"

class OsuClassesFetcher
  include HTTParty
  base_uri "https://content.osu.edu"
  
  # SSL configuration for development
  if Rails.env.development?
    default_options[:verify] = false
    default_options[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE
  end

  DEFAULTS = {
    client: "class-search-ui",
    campus: "col",
    "academic-career": "ugrad",
    q: "",
    subject: "cse"
  }.freeze

  def self.fetch_and_save!(term:, campus:, subject: "cse")
    new.fetch_and_save!(term: term, campus: campus, subject: subject)
  end

  def self.fetch_courses(term:, campus: "col", subject: "cse", keyword: nil, course_number: nil, level: nil)
    new.fetch_courses(term: term, campus: campus, subject: subject, keyword: keyword, course_number: course_number, level: level)
  end

  def fetch_and_save!(term:, campus: "col", subject: "cse")
    raise ArgumentError, "term is required" if term.blank?

    @term = term
    @campus = campus
    @subject = subject.presence

    total_processed = 0
    page = 1

    loop do
      json   = fetch_page(page)
      items  = Array(json.dig("data", "courses"))            
      items  = Array(json.dig("data", "classes")) if items.empty? 
      items  = Array(json.dig("data", "items"))   if items.empty? 
      break if items.empty?

      upsert_batch(items)
      total_processed += items.size

      current = json.dig("data", "currentItemCount").to_i
      total   = json.dig("data", "totalItems").to_i
      break if current.zero? || (page * current) >= total

      page += 1
    end

    total_processed
  end

  def fetch_courses(term:, campus: "col", subject: "cse", keyword: nil, course_number: nil, level: nil)
    raise ArgumentError, "term is required" if term.blank?

    @term = term
    @campus = campus
    @subject = subject.presence
    @keyword = keyword
    @course_number = course_number
    @level = level

    all_courses = []
    page = 1

    loop do
      json = fetch_page(page)
      items = Array(json.dig("data", "courses"))            
      items = Array(json.dig("data", "classes")) if items.empty? 
      items = Array(json.dig("data", "items"))   if items.empty? 
      break if items.empty?

      # Convert API data to course objects without saving to database
      courses = items.map { |item| convert_to_course_object(item) }
      
      # Apply client-side filtering
      courses = apply_filters(courses)
      
      all_courses.concat(courses)

      current = json.dig("data", "currentItemCount").to_i
      total   = json.dig("data", "totalItems").to_i
      break if current.zero? || (page * current) >= total

      page += 1
    end

    all_courses
  end

  private

  def convert_to_course_object(item)
    course_obj = item["course"] || {} 
    
    # Extract course data
    subject = (course_obj["subject"] || course_obj["subjectCode"] || "CSE").to_s.upcase   
    catalog_number = (course_obj["catalogNumber"] || course_obj["courseNumber"]).to_s           
    title = course_obj["courseTitle"] || course_obj["title"]                           
    short_desc = course_obj["shortDescription"] || course_obj["descrshort"]                 
    long_desc = course_obj["description"] || course_obj["courseDescription"] || course_obj["descrlong"]  
    term_name = course_obj["term"].presence      
    campus_name = course_obj["campus"].presence 

    # Extract sections data
    sections = Array(item["sections"] || item["classSections"]).map do |sec|
      {
        class_number: (sec["classNumber"] || sec["classNbr"]).to_s,
        section_code: sec["section"] || sec["sectionNumber"],
        component: sec["component"] || sec["componentCode"],
        instruction_mode: sec["instructionMode"] || sec["instructionModeDescrShort"],
        enrollment_status: sec["enrollmentStatus"] || sec["enrlStatus"],
        location: extract_location(sec),
        meeting_days: extract_meeting_days(sec),
        start_date: parse_date(sec["startDate"]),
        end_date: parse_date(sec["endDate"])
      }
    end

    # Return a course-like object
    {
      subject: subject,
      catalog_number: catalog_number,
      title: title,
      short_description: short_desc,
      description: long_desc,
      term: term_name || @term,
      campus: campus_name || @campus,
      sections: sections,
      sections_count: sections.count
    }
  end

  def extract_location(sec)
    meetings = Array(sec["meetings"] || sec["meetingPatterns"])
    first_meet = meetings.first || {}
    [first_meet["facilityDescrShort"], first_meet["facilityDescr"]].compact.join(" / ").presence
  end

  def extract_meeting_days(sec)
    meetings = Array(sec["meetings"] || sec["meetingPatterns"])
    first_meet = meetings.first || {}
    first_meet["days"] || first_meet["meetingDays"]
  end

  def apply_filters(courses)
    courses = courses.select { |c| c[:subject] == @subject.upcase } if @subject.present?
    courses = courses.select { |c| c[:catalog_number] == @course_number } if @course_number.present?
    courses = courses.select { |c| c[:catalog_number].start_with?(@level.first) } if @level&.match?(/\A[1-9]xxx\z/)
    
    if @keyword.present?
      keyword_lower = @keyword.strip.downcase
      courses = courses.select do |c|
        c[:title]&.downcase&.include?(keyword_lower) ||
        c[:short_description]&.downcase&.include?(keyword_lower) ||
        c[:description]&.downcase&.include?(keyword_lower)
      end
    end

    courses
  end

  def fetch_page(page)
    query = {
      client: DEFAULTS[:client],
      campus: @campus,
      p: page,
      term: @term,
      q: @subject || "cse"
    }

    Rails.logger.debug "Fetching OSU API page #{page} with query: #{query.inspect}"
    resp = self.class.get("/v2/classes/search",
                         query: query,
                         timeout: 25)

    unless resp.success?
      Rails.logger.error "OSU API error: HTTP #{resp.code} - #{resp.body}"
      raise "OSU API error: HTTP #{resp.code}"
    end

    Rails.logger.debug "Received #{resp.parsed_response.dig('data', 'courses')&.size || 0} courses from API"
    resp.parsed_response
  end

  def upsert_batch(items)
    ApplicationRecord.transaction do
      items.each do |item|
        course_obj = item["course"] || {} 
        ext_course_id  = course_obj["courseId"] || course_obj["courseID"] || course_obj["id"]&.to_s 
        subject        = (course_obj["subject"] || course_obj["subjectCode"] || "CSE").to_s.upcase   
        catalog_number = (course_obj["catalogNumber"] || course_obj["courseNumber"]).to_s           
        title          = course_obj["courseTitle"] || course_obj["title"]                           
        short_desc     = course_obj["shortDescription"] || course_obj["descrshort"]                 
        long_desc      = course_obj["description"] || course_obj["courseDescription"] || course_obj["descrlong"]  
        term_name   = course_obj["term"].presence      
        campus_name = course_obj["campus"].presence 

        course = Course.find_or_initialize_by(
          subject: subject,
          catalog_number: catalog_number,
          term:   (term_name   || @term),     
          campus: (campus_name || @campus) 
        )
        course.course_id         = ext_course_id
        course.title             = title
        course.short_description = short_desc
        course.description       = long_desc
        course.term              = (term_name || @term)    
        course.campus            = (campus_name || @campus)
        course.save!

        Array(item["sections"] || item["classSections"]).each do |sec|
          class_number     = (sec["classNumber"] || sec["classNbr"]).to_s
          section_code     = sec["section"] || sec["sectionNumber"]
          component        = sec["component"] || sec["componentCode"]
          instruction_mode = sec["instructionMode"] || sec["instructionModeDescrShort"]
          enroll_status    = sec["enrollmentStatus"] || sec["enrlStatus"]

          meetings   = Array(sec["meetings"] || sec["meetingPatterns"])
          first_meet = meetings.first || {}
          meeting_day = first_meet["days"] || first_meet["meetingDays"]
          meeting_start = first_meet["startTime"] || first_meet["meetingStartTime"]
          meeting_end = first_meet["endTime"] || first_meet["meetingEndTime"]
          location     = [first_meet["facilityDescrShort"], first_meet["facilityDescr"]].compact.join(" / ").presence

          start_date = parse_date(sec["startDate"] || first_meet["startDate"])
          end_date   = parse_date(sec["endDate"]   || first_meet["endDate"])

          section = Section.find_or_initialize_by(course_id: course.id, class_number: class_number)
          section.section_code      = section_code
          section.component         = component
          section.instruction_mode  = instruction_mode
          section.enrollment_status = enroll_status
          section.location          = location
          section.meeting_day       = meeting_day
          section.meeting_start     = meeting_start
          section.meeting_end       = meeting_end
          section.start_date        = start_date
          section.end_date          = end_date
          section.save!
        end
      end
    end
  end

  def parse_date(str)
    return nil if str.blank?
    Date.parse(str) rescue nil
  end
end
