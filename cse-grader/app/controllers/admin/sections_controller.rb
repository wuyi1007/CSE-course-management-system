# app/controllers/admin/sections_controller.rb
module Admin
  class SectionsController < BaseController
    before_action :set_course, only: [:index, :new, :create]
    before_action :set_section, only: [:edit, :update, :destroy]

    # GET /admin/courses/:course_id/sections
    def index
      @sections = @course.sections.order(:section_code)
      @sections = @sections.where(semester: params[:semester]) if params[:semester].present?
    end

    # GET /admin/courses/:course_id/sections/new
    def new
      @section = @course.sections.new
    end

    # POST /admin/courses/:course_id/sections
    def create
      @section = @course.sections.new(section_params)

      begin
        generated = SecureRandom.random_number(100000).to_s.rjust(5, "0")
      end while Section.exists?(class_number: generated)

      @section.class_number = generated

      if @section.component.present?
        case @section.component.upcase
        when "LAB"
          @section.section_type = "lab"
        else
          @section.section_type = "lecture"
        end
      end

      if @section.save
        redirect_to admin_course_sections_path(@course), notice: "Section created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end


    # GET /admin/sections/:id/edit
    def edit
    end

    # PATCH/PUT /admin/sections/:id
    def update
      if @section.update(section_params)
        redirect_to admin_course_sections_path(@course), notice: "Section updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/sections/:id
    def destroy
      course = @section.course
      @section.destroy
      redirect_to admin_course_sections_path(course), notice: "Section deleted successfully."
    end

    private

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_section
      @section = Section.find(params[:id])
    end

    def section_params
      params.require(:section).permit(
        :section_code,
        :semester,
        :meeting_day,
        :meeting_start,
        :meeting_end,
        :required_graders,
        :section_type,
        :component,
        :instruction_mode,
        :location,
        :start_date,
        :end_date
      )
    end
  end
end
