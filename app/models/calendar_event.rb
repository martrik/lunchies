class CalendarEvent < ApplicationRecord
  belongs_to :team

  enum provider: {
    google: "google"
  }
end
