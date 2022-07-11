class Counts < ApplicationRecord
  validates :departures_performed, presence: true
  validates :departures_performed, numericality: { greater_than_or_equal_to: 0 }
  validates :departures_scheduled, presence: true
  validates :departures_performed, numericality: { greater_than_or_equal_to: 0 }
  validates :seats, presence: true
  validates :seats, numericality: { greater_than_or_equal_to: 0 }
  validates :passengers, presence: true
  validates :passengers, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :aircraft
  belongs_to :airline
  belongs_to :origin_airport, class_name: 'Airport'
  belongs_to :destination_airport, class_name: 'Airport'
  belongs_to :time_period
end
