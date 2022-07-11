class Aircraft < ApplicationRecord
  self.table_name = 'aircraft'

  validates :name, presence: true
  validates :group, presence: true
  validates :bts_id, presence: true

  def self.select_options
    all.order(:name).map do |aircraft|
      [aircraft.name, aircraft.id]
    end
  end
end
