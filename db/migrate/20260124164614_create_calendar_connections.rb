class CreateCalendarConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_connections do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :provider, default: "google", null: false
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.string :google_email

      t.timestamps
    end
  end
end
