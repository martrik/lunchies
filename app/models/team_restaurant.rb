class TeamRestaurant < ApplicationRecord
  belongs_to :team
  belongs_to :restaurant
end
