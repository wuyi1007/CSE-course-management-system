class User < ApplicationRecord
  # Devise authentication modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Define user roles
    enum role: { student: 0, instructor: 1, admin: 2 }

  # OSU email format validation
  VALID_OSU_EMAIL = /\A[a-z0-9]+\.[0-9]+@osu\.edu\z/i
  validates :email, format: { with: VALID_OSU_EMAIL, message: "must be in the format name.#@osu.edu" }

  # Auto-approve students
  before_validation :set_default_approval

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : :not_approved
  end
  
  private

  def auto_approve_students
    self.approved = true if role == "student"
  end
  
 # NEW: instructors/admins start unapproved unless explicitly set(Yibo Su)
  def set_default_approval
    if role == "student"
      self.approved = true
    else
      self.approved = false if approved.nil?
    end
  end
end
