class Course < ApplicationRecord
  has_many :sections, dependent: :destroy
  
  # Validations
  validates :course_id, presence: true, uniqueness: true
  validates :subject, presence: true, length: { maximum: 10 }
  validates :catalog_number, presence: true, length: { maximum: 10 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :term, presence: true
  validates :campus, presence: true
  
  # Scopes for filtering
  scope :by_subject, ->(subject) { where(subject: subject.upcase) if subject.present? }
  scope :by_level, ->(level) { where("catalog_number LIKE ?", "#{level.first}%") if level&.match?(/\A[1-9]xxx\z/) }
  scope :by_term, ->(term) { where(term: term) if term.present? }
  scope :by_campus, ->(campus) { where("UPPER(campus) = ?", campus.upcase) if campus.present? }
  scope :search_by_keyword, ->(keyword) do
    if keyword.present?
      where(
        arel_table[:title].matches("%#{keyword.strip}%")
          .or(arel_table[:short_description].matches("%#{keyword.strip}%"))
          .or(arel_table[:description].matches("%#{keyword.strip}%"))
      )
    end
  end
  
  # Display methods
  def full_course_code
    "#{subject} #{catalog_number}"
  end
  
  def sections_count
    sections.count
  end
end

class Section < ApplicationRecord
  belongs_to :course
  
  # Validations
  validates :class_number, presence: true, uniqueness: { scope: :course_id }
  validates :section_code, presence: true
  validates :component, presence: true
  validates :instruction_mode, presence: true
  
  # Scopes
  scope :by_component, ->(component) { where(component: component) if component.present? }
  scope :by_mode, ->(mode) { where(instruction_mode: mode) if mode.present? }
  scope :open_enrollment, -> { where(enrollment_status: 'Open') }
  
  # Display methods
  def full_section_info
    "#{class_number} (#{section_code}) - #{component} #{instruction_mode}"
  end
  
  def enrollment_open?
    enrollment_status&.downcase == 'open'
  end
end