class TimePeriod < ApplicationRecord
  validates :name, presence: true
  validates :year, presence: true
  validates :month, presence: true
end
