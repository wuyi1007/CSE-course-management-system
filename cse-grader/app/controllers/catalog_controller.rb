class CatalogController < ApplicationController
  include Pagy::Backend

  # Restrict catalog access to authenticated users across all roles
  before_action -> { require_role!(:student, :instructor, :admin) }

  def index
    scope = Course.order(subject: :asc, catalog_number: :asc)
    @q_subject = params[:subject].presence
    @q_level   = params[:level].presence # like "2xxx"
    @q_term    = params[:term].presence
    @q_campus  = params[:campus].presence
    @q_keyword = params[:q].presence
    @q_number = params[:course_number].to_s.strip.presence
    scope = scope.where(catalog_number: @q_number) if @q_number


    scope = scope.where(subject: @q_subject.upcase) if @q_subject
    scope = scope.where("catalog_number LIKE ?", "#{@q_level.first}%") if @q_level&.match?(/\A[1-9]xxx\z/)
    
    # Normalize term input to full term name
    if @q_term
      term_norm = normalize_term(@q_term)          
      scope = scope.where(term: [@q_term, term_norm].compact.uniq)
    end

    # Normalize campus input to full campus name
    if @q_campus
      campus_norm = normalize_campus(@q_campus)           
      scope = scope.where(
        "UPPER(campus) = ? OR UPPER(campus) = ?",
        @q_campus.upcase, campus_norm.upcase
      )
    end
    scope = scope.where(catalog_number: @q_number) if @q_number

    if @q_keyword
      like_query = "%#{@q_keyword.strip}%"
      scope = scope.where(
        Course.arel_table[:title].matches(like_query)
          .or(Course.arel_table[:short_description].matches(like_query))
          .or(Course.arel_table[:description].matches(like_query))
      )
    end

    @pagy, @courses = pagy(scope, items: 20)     
  end


  private

  # Normalize term codes to full term names
  def normalize_term(val)
    {
      "1262" => "Spring 2026",
      "1248" => "Autumn 2024",
      "1252" => "Spring 2025",
      "1254" => "Summer 2025"
    }[val.to_s] || val
  end

  # Normalize campus codes to full campus names
  def normalize_campus(val)
    code = val.to_s.downcase
    {
      "col" => "Columbus",
      "lma" => "Lima",
      "mns" => "Mansfield",
      "mrn" => "Marion",
      "nwk" => "Newark",
      "wst" => "Wooster"
    }[code] || val
  end
end
