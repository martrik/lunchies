class Lunch < ApplicationRecord
  belongs_to :team
  belongs_to :restaurant
end
