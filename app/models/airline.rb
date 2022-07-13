class Airline < ApplicationRecord
  validates :iata, presence: true

  def self.select_options
    all.order(:iata).map do |airline|
      [airline.iata, airline.id]
    end
  end
end
