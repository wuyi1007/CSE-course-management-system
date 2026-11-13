class AddFinalProjectFieldsToSections < ActiveRecord::Migration[7.2]
  def change
    add_column :sections, :semester, :string
    add_column :sections, :meeting_day, :string
    add_column :sections, :meeting_start, :string
    add_column :sections, :meeting_end, :string
    add_column :sections, :required_graders, :integer
    add_column :sections, :section_type, :string
  end
end
