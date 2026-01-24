class GooglePlacesService
  BASE_URL = "https://places.googleapis.com/v1".freeze

  class << self
    def search_nearby_restaurants(latitude:, longitude:, radius:, categories: [], price_levels: [])
      response = connection.post("places:searchNearby") do |req|
        req.headers["X-Goog-FieldMask"] = field_mask_for_search
        req.body = build_search_body(latitude, longitude, radius, categories, price_levels)
      end

      parse_search_response(response)
    end

    def get_place_reviews(place_id:, max_reviews: 5)
      response = connection.get("places/#{place_id}") do |req|
        req.headers["X-Goog-FieldMask"] = "reviews"
      end

      parse_reviews_response(response, max_reviews)
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.response :json
        f.headers["X-Goog-Api-Key"] = api_key
      end
    end

    def api_key
      Rails.application.config.google_places_api_key
    end

    def field_mask_for_search
      %w[
        places.id
        places.displayName
        places.formattedAddress
        places.rating
        places.userRatingCount
        places.priceLevel
        places.types
        places.primaryType
        places.location
      ].join(",")
    end

    def build_search_body(latitude, longitude, radius, categories, price_levels)
      body = {
        locationRestriction: {
          circle: {
            center: { latitude: latitude, longitude: longitude },
            radius: radius.to_f
          }
        },
        maxResultCount: 20
      }

      included_types = categories.presence || [ "restaurant" ]
      body[:includedTypes] = included_types

      if price_levels.present?
        body[:priceLevels] = price_levels
      end

      body
    end

    def parse_search_response(response)
      return [] unless response.success? && response.body["places"]

      response.body["places"].map do |place|
        {
          place_id: place["id"],
          name: place.dig("displayName", "text"),
          address: place["formattedAddress"],
          rating: place["rating"],
          user_ratings_count: place["userRatingCount"],
          price_level: place["priceLevel"],
          types: place["types"],
          primary_type: place["primaryType"],
          location: place["location"]
        }
      end
    end

    def parse_reviews_response(response, max_reviews)
      return [] unless response.success? && response.body["reviews"]

      response.body["reviews"].first(max_reviews).map do |review|
        {
          text: review.dig("text", "text"),
          rating: review["rating"],
          relative_time: review["relativePublishTimeDescription"]
        }
      end
    end
  end
end
