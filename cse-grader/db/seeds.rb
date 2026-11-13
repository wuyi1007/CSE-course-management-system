# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Default admin is also created during boot via config/initializers/default_admin.rb
# Seeds keep the same credentials for first-time database setup.
User.find_or_create_by!(email: 'admin.1@osu.edu') do |u|
  u.password              = 'AdminPassword123!'
  u.password_confirmation = 'AdminPassword123!'
  u.role                  = :admin
  u.approved              = true
end

puts "Seeded admin: admin.1@osu.edu / AdminPassword123!"


course = Course.find_or_create_by!(course_id: "TEST-2221") do |c|
  c.subject = "CSE"
  c.catalog_number = "2221"
  c.title = "Software I: Components"
  c.short_description = "Sample course (seeded)"
  c.description = "Seed data so the UI renders even if the API has no data."
  c.term = "Autumn 2025"
  c.campus = "Columbus"
end

course.sections.find_or_create_by!(class_number: "99999") do |s|
  s.section_code = "0010"
  s.component = "Lecture"
  s.instruction_mode = "In Person"
  s.enrollment_status = "Open"
  s.location = "DL 357"
  s.meeting_days = "MTWRF"
  s.start_date = Date.today
  s.end_date = Date.today + 60
end
puts "Seeded sample course + section."
