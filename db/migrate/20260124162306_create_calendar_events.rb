class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events do |t|
      t.references :team, null: false, foreign_key: true
      t.string :calendar_id
      t.string :event_id
      t.string :provider
      t.string :refresh_token
      t.datetime :last_synced_at

      t.timestamps
    end
  end
end
