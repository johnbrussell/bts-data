require 'csv'

class Data::InputBts < ApplicationRecord
  DATA_LOCATION = {
    year: 0,
    month: 1,
    origin_iata: 2,
    origin: 5,
    destination_iata: 6,
    destination_name: 9,
    airline_iata: 10,
    aircraft_group: 15,
    aircraft_bts_id: 16,
    departures_performed: 18,
    departures_scheduled: 19,
    seats: 21,
    passengers: 22,
  }

  def self.run
    aircraft = Aircraft.pluck(:bts_id, :id).to_h
    airlines = Airline.pluck(:iata, :id).to_h
    airports = Airport.pluck(:iata, :id).to_h
    time_periods = TimePeriod.pluck(:name, :id).to_h

    self.files.each do |f|
      records = []

      CSV.foreach(File.read(f), headers: false) do |d|
        aircraft_id = aircraft[d[DATA_LOCATION[:aircraft_bts_id]]]
        airline_id = self.get_airline_id(airlines, d[DATA_LOCATION[:airline_iata]])
        origin_airport_id = self.get_airport_id(airports, d[DATA_LOCATION[:origin_iata]], d[DATA_LOCATION[:origin_name]])
        destination_airport_id = self.get_airport_id(airports, d[DATA_LOCATION[:destination_iata]], d[DATA_LOCATION[:destination_name]])
        time_period_id = self.get_time_period(time_periods, d[DATA_LOCATION[:month]], d[DATA_LOCATION[:year]])
      end
    end
  end

  def self.files
    Dir.glob("data/bts/*")
  end

  def self.get_airline_id(airlines, iata)
    unless airlines.include?(iata)
      airlines[iata] = Airline.create!(iata: iata).id
    end
    airlines[iata]
  end


  def self.get_airport_id(airports, iata, name)
    unless airports.include(iata)
      airports[iata] = Airport.create!(iata: iata, name: name).id
    end
    airports[iata]
  end

  def self.get_time_period(time_periods, month, year)
    name = self.get_time_period_name(month, year)
    unless time_periods.include?(name)
      time_periods[name] = TimePeriod.create!(month: month, year: year, name: name).id
    end
    time_periods[name]
  end

  def self.get_time_period_name(month, year)
    ((year.to_s + (month + 10).to_s).to_i - 10).to_s
  end
end
