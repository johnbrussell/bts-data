class Airport < ApplicationRecord
  validates :iata, presence: true
  validates :name, presence: true

  def self.select_options
    all.order(:iata).map do |airport|
      ["#{airport.iata} - #{airport.name}", airport.id]
    end
  end
end
