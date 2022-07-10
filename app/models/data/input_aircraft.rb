require 'csv'

class Data::InputAircraft < ApplicationRecord
  def self.run
    self.data.by_row.each do |data_point|
      data_map = {
        bts_id: data_point["AC_TYPEID"],
        name: data_point["SSD_NAME"],
        group: data_point["AC_GROUP"],
      }
      unless Aircraft.exists?(bts_id: data_map[:bts_id], group: data_map[:group])
        Aircraft.create!(**data_map)
      end
    end
  end

  def self.data
    CSV.parse(File.read("data/aircraft_types.csv"), headers: true)
  end
end
