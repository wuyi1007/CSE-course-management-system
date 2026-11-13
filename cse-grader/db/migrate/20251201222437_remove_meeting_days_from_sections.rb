class RemoveMeetingDaysFromSections < ActiveRecord::Migration[7.2]
  def change
    remove_column :sections, :meeting_days, :string
  end
end
