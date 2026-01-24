class AddUserIdToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_reference :calendar_events, :user, null: false, foreign_key: true
  end
end
