class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses do |t|
      t.string :course_id
      t.string :subject
      t.string :catalog_number
      t.string :title
      t.string :short_description
      t.text :description
      t.string :term
      t.string :campus

      t.timestamps
    end
  end
end
