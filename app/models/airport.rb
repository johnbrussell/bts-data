class Airport < ApplicationRecord
  validates :iata, presence: true
  validates :name, presence: true
end
