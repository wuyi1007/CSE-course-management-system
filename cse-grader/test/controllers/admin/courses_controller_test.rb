require "test_helper"

class Admin::CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(
      email: "admin.test@osu.edu",
      password: "password123",
      password_confirmation: "password123",
      role: :admin,
      approved: true
    )
    @course = Course.create!(
      course_id: "TEST-1234",
      subject: "CSE",
      catalog_number: "1234",
      title: "Test Course",
      term: "1248",
      campus: "Columbus"
    )
  end

  test "should get index" do
    sign_in @admin
    get admin_courses_url
    assert_response :success
  end

  test "should get new" do
    sign_in @admin
    get new_admin_course_url
    assert_response :success
  end

  test "should create course" do
    sign_in @admin
    assert_difference('Course.count') do
      post admin_courses_url, params: { 
        course: { 
          course_id: "TEST-5678",
          subject: "CSE",
          catalog_number: "5678",
          title: "New Test Course",
          term: "1248",
          campus: "Columbus"
        } 
      }
    end
    assert_redirected_to admin_course_url(Course.last)
  end

  test "should show course" do
    sign_in @admin
    get admin_course_url(@course)
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get edit_admin_course_url(@course)
    assert_response :success
  end

  test "should update course" do
    sign_in @admin
    patch admin_course_url(@course), params: { 
      course: { title: "Updated Test Course" } 
    }
    assert_redirected_to admin_course_url(@course)
    @course.reload
    assert_equal "Updated Test Course", @course.title
  end

  test "should destroy course" do
    sign_in @admin
    assert_difference('Course.count', -1) do
      delete admin_course_url(@course)
    end
    assert_redirected_to admin_courses_url
  end

  test "should require admin role" do
    student = User.create!(
      email: "student.test@osu.edu",
      password: "password123",
      password_confirmation: "password123",
      role: :student,
      approved: true
    )
    sign_in student
    get admin_courses_url
    assert_redirected_to root_url
  end
end

