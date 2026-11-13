class Admin::CoursesController < Admin::BaseController
  include Pagy::Backend
  
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  
  def index
    @q_subject = params[:subject].presence
    @q_level = params[:level].presence
    @q_term = params[:term].presence
    @q_campus = params[:campus].presence
    @q_keyword = params[:q].presence
    
    scope = Course.includes(:sections).order(subject: :asc, catalog_number: :asc)
    
    scope = scope.where(subject: @q_subject.upcase) if @q_subject
    scope = scope.where("catalog_number LIKE ?", "#{@q_level.first}%") if @q_level&.match?(/\A[1-9]xxx\z/)
    scope = scope.where(term: @q_term) if @q_term
    scope = scope.where("UPPER(campus) = ?", @q_campus.upcase) if @q_campus
    
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
  
  def show
    @sections = @course.sections.order(:class_number)
  end
  
  def new
    @course = Course.new
  end
  
  def create
    @course = Course.new(course_params)
    
    if @course.save
      redirect_to admin_course_path(@course), notice: 'Course was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @course.update(course_params)
      redirect_to admin_course_path(@course), notice: 'Course was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @course.destroy!
    redirect_to admin_courses_path, notice: 'Course was successfully deleted.'
  end
  
  private
  
  def set_course
    @course = Course.find(params[:id])
  end
  
  def course_params
    params.require(:course).permit(
      :course_id, :subject, :catalog_number, :title, 
      :short_description, :description, :term, :campus
    )
  end
end

