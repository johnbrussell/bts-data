class Airline < ApplicationRecord
  validates :iata, presence: true
end
