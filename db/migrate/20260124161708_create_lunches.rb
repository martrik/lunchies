class CreateLunches < ActiveRecord::Migration[8.1]
  def change
    create_table :lunches do |t|
      t.references :team, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.datetime :occurred_at
      t.boolean :booked
      t.text :booked_details

      t.timestamps
    end
  end
end
