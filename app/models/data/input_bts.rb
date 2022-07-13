require 'csv'

class Data::InputBts < ApplicationRecord
  DATA_LOCATION = {
    year: 0,
    month: 1,
    origin_iata: 2,
    origin_name: 5,
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
    aircraft = Aircraft.all.pluck(:bts_id, :id).to_h
    airlines = Airline.all.pluck(:iata, :id).to_h
    airports = Airport.all.pluck(:iata, :id).to_h
    time_periods = TimePeriod.all.pluck(:name, :id).to_h

    self.files.each do |f|
      records = []

      CSV.foreach(f, headers: false, col_sep: "|") do |d|
        if d[DATA_LOCATION[:seats]].to_i > 0 && d[DATA_LOCATION[:departures_scheduled]].to_i > 0
          aircraft_id = self.get_aircraft_id(aircraft, d[DATA_LOCATION[:aircraft_group]], d[DATA_LOCATION[:aircraft_bts_id]])
          airline_id = self.get_airline_id(airlines, d[DATA_LOCATION[:airline_iata]])
          origin_airport_id = self.get_airport_id(airports, d[DATA_LOCATION[:origin_iata]], d[DATA_LOCATION[:origin_name]])
          destination_airport_id = self.get_airport_id(airports, d[DATA_LOCATION[:destination_iata]], d[DATA_LOCATION[:destination_name]])
          time_period_id = self.get_time_period(time_periods, d[DATA_LOCATION[:month]], d[DATA_LOCATION[:year]])

          unless Counts.exists?(aircraft_id: aircraft_id, airline_id: airline_id, origin_airport_id: origin_airport_id, destination_airport_id: destination_airport_id, time_period_id: time_period_id)
            Counts.create!(
              aircraft_id: aircraft_id,
              airline_id: airline_id,
              origin_airport_id: origin_airport_id,
              destination_airport_id: destination_airport_id,
              time_period_id: time_period_id,
              departures_performed: d[DATA_LOCATION[:departures_performed]],
              departures_scheduled: d[DATA_LOCATION[:departures_scheduled]],
              seats: d[DATA_LOCATION[:seats]],
              passengers: d[DATA_LOCATION[:passengers]],
            )
          end
        end
      end

      ProcessedFile.create!(name: f)
    end
  end

  def self.files
    processed_files = ProcessedFile.pluck(:name)

    Dir.glob("data/bts/*").reject { |f| processed_files.include?(f) }
  end

  def self.get_aircraft_id(aircraft, group, bts_id)
    if aircraft.include?(bts_id.to_i)
      aircraft[bts_id.to_i]
    else
      aircraft[self.get_aircraft_id_from_group_and_partial_bts_id(group, bts_id).to_i]
    end
  end

  def self.get_aircraft_id_from_group_and_partial_bts_id(group, partial_bts_id)
    bts_id = if partial_bts_id.to_i >= 10
      partial_bts_id.to_s
    else
      (partial_bts_id.to_i + 100).to_s[1..-1]
    end
    group.to_s + bts_id
  end

  def self.get_airline_id(airlines, iata)
    unless airlines.include?(iata)
      airlines[iata] = Airline.create!(iata: iata).id
    end
    airlines[iata]
  end

  def self.get_airport_id(airports, iata, name)
    unless airports.include?(iata)
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
    ((year.to_s + (month.to_i + 10).to_s).to_i - 10).to_s
  end
end
