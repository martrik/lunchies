class RestaurantSearch
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Google Places API restaurant/food types (Table A)
  CATEGORIES = %w[
    restaurant
    american_restaurant
    barbecue_restaurant
    brazilian_restaurant
    chinese_restaurant
    french_restaurant
    greek_restaurant
    indian_restaurant
    indonesian_restaurant
    italian_restaurant
    japanese_restaurant
    korean_restaurant
    mexican_restaurant
    mediterranean_restaurant
    middle_eastern_restaurant
    spanish_restaurant
    thai_restaurant
    turkish_restaurant
    vietnamese_restaurant
    seafood_restaurant
    steak_house
    sushi_restaurant
    vegetarian_restaurant
    vegan_restaurant
    pizza_restaurant
    hamburger_restaurant
    sandwich_shop
    cafe
    coffee_shop
    bakery
    bar
    fast_food_restaurant
  ].freeze

  # Google Places API price levels
  PRICE_LEVELS = %w[
    PRICE_LEVEL_FREE
    PRICE_LEVEL_INEXPENSIVE
    PRICE_LEVEL_MODERATE
    PRICE_LEVEL_EXPENSIVE
    PRICE_LEVEL_VERY_EXPENSIVE
  ].freeze

  attribute :latitude, :float
  attribute :longitude, :float
  attribute :radius, :integer, default: 1000
  attribute :categories, default: -> { [] }
  attribute :price_levels, default: -> { [] }
  attribute :additional_requirements, default: -> { [] }

  validates :latitude, presence: true, numericality: { in: -90..90 }
  validates :longitude, presence: true, numericality: { in: -180..180 }
  validates :radius, numericality: { in: 1..50000 }
  validate :validate_categories
  validate :validate_price_levels

  private

  def validate_categories
    invalid = Array(categories) - CATEGORIES
    errors.add(:categories, "invalid: #{invalid.join(', ')}") if invalid.any?
  end

  def validate_price_levels
    invalid = Array(price_levels) - PRICE_LEVELS
    errors.add(:price_levels, "invalid: #{invalid.join(', ')}") if invalid.any?
  end
end
