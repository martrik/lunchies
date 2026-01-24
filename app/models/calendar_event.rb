class CalendarEvent < ApplicationRecord
  belongs_to :team
  belongs_to :user

  enum provider: {
    google: "google"
  }
end
