class RestaurantFinderAgent < ApplicationAgent
  generate_with :openai, model: "gpt-5.2", reasoning: { effort: "low" }, instructions: true

  RECOMMENDATION_SCHEMA = {
    type: "object",
    properties: {
      recommendations: {
        type: "array",
        items: {
          type: "object",
          properties: {
            name: { type: "string", description: "Restaurant name" },
            address: { type: "string", description: "Full address" },
            rating: { type: "number", description: "Google rating (1-5)" },
            priceLevel: { type: "string", description: "Price level" },
            cuisine: { type: "string", description: "Primary cuisine type" },
            reason: { type: "string", description: "Why this restaurant was recommended" },
            additionalRequirementsInfo: {
              type: "object",
              properties: {
                meetsRequirements: { type: "boolean", description: "Whether the restaurant meets the additional requirements" },
                confidence: { type: "string", enum: %w[high medium low], description: "Confidence level based on review evidence" },
                evidence: { type: "string", description: "Summary of evidence from reviews" }
              },
              required: %w[meetsRequirements confidence evidence],
              additionalProperties: false
            }
          },
          required: %w[name address rating priceLevel cuisine reason additionalRequirementsInfo],
          additionalProperties: false
        },
        maxItems: 3
      }
    },
    required: [ "recommendations" ],
    additionalProperties: false
  }.freeze

  AGENT_TOOLS = [
    {
      name: "search_restaurants",
      description: "Search for nearby restaurants based on location and filters",
      parameters: {
        type: "object",
        properties: {
          latitude: { type: "number", description: "Latitude coordinate" },
          longitude: { type: "number", description: "Longitude coordinate" },
          radius: { type: "integer", description: "Search radius in meters (default: 1000)" },
          categories: {
            type: "array",
            items: { type: "string" },
            description: "Cuisine categories to filter by"
          },
          price_levels: {
            type: "array",
            items: { type: "string" },
            description: "Price levels to filter by"
          }
        },
        required: %w[latitude longitude radius categories price_levels],
        additionalProperties: false
      }
    },
    {
      name: "get_reviews",
      description: "Get customer reviews for a specific restaurant",
      parameters: {
        type: "object",
        properties: {
          place_id: { type: "string", description: "Google Places ID of the restaurant" },
          max_reviews: { type: "integer", description: "Maximum number of reviews to fetch", default: 20 }
        },
        required: %w[place_id max_reviews],
        additionalProperties: false
      }
    }
  ].freeze

  def recommend
    lines = [ "Find restaurants with the following criteria:",
             "- Location: #{params[:latitude]}, #{params[:longitude]}",
             "- Radius: #{params[:radius] || 2000} meters" ]
    lines << "- Categories: #{params[:categories].join(', ')}" if params[:categories].present?
    lines << "- Price levels: #{params[:price_levels].join(', ')}" if params[:price_levels].present?
    if params[:additional_requirements].present?
      lines << "- Additional requirements: #{params[:additional_requirements].join(', ')}"
      lines << "Please check reviews for these additional requirements and include confidence levels."
    end

    prompt(
      message: lines.join("\n"),
      tools: AGENT_TOOLS,
      response_format: { type: "json_schema", json_schema: { name: "recommendations", schema: RECOMMENDATION_SCHEMA } }
    )
  end

  def search_restaurants(latitude:, longitude:, radius:, categories:, price_levels:)
    GooglePlacesService.search_nearby_restaurants(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      categories: categories,
      price_levels: price_levels
    )
  end

  def get_reviews(place_id:, max_reviews:)
    GooglePlacesService.get_place_reviews(
      place_id: place_id,
      max_reviews: max_reviews
    )
  end
end
