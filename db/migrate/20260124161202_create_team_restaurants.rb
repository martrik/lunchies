class CreateTeamRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :team_restaurants do |t|
      t.references :team, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
