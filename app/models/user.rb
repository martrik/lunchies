class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_one :calendar_connection, dependent: :destroy
  has_many :calendar_events, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
