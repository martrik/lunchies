class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.float :rating
      t.integer :user_ratings_count
      t.string :price_level
      t.json :types, default: []
      t.string :primary_type

      t.timestamps
    end
  end
end
