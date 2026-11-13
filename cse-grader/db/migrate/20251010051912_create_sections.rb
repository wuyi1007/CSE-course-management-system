class CreateSections < ActiveRecord::Migration[7.2]
  def change
    create_table :sections do |t|
      t.references :course, null: false, foreign_key: true
      t.string :class_number
      t.string :section_code
      t.string :component
      t.string :instruction_mode
      t.string :enrollment_status
      t.string :location
      t.string :meeting_days
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
