class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.float :latitude
      t.float :longiute

      t.timestamps
    end
  end
end
