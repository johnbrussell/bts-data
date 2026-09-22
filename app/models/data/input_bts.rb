require 'csv'

BATCH_SIZE = 100
COMBI_CONFIG_TYPE = '3'
COMBI_SUFFIX = 'COMBI'
VALID_SERVICE_TYPES = ['F', 'G']

class Data::InputBts < ApplicationRecord
  DATA_LOCATION = {
    year: 0,
    month: 1,
    origin_iata: 2,
    origin_name: 5,
    destination_iata: 6,
    destination_name: 9,
    airline_iata: 10,
    service_type: 14,
    aircraft_group: 15,
    aircraft_bts_id: 16,
    aircraft_configuration_type: 17,
    departures_performed: 18,
    departures_scheduled: 19,
    seats: 21,
    passengers: 22,
  }

  def self.run
    self.unfinished_files.each do |f|
      self.insert_file_data(f)
    end
  end

  def self.run_once
    processed_file_count = ProcessedFile.count
    self.unfinished_files.each do |f|
      self.insert_file_data(f)
      if ProcessedFile.count > processed_file_count
        break
      end
    end
  end

  def self.get_aircraft_id(aircraft, group, bts_id, config_type)
    non_combi_aircraft = if aircraft.include?(bts_id.to_i) && bts_id.to_i >= 100
                           aircraft[bts_id.to_i]
                         else
                           aircraft[self.get_aircraft_id_from_group_and_partial_bts_id(group, bts_id).to_i]
                         end
    if config_type == COMBI_CONFIG_TYPE
      Aircraft.find_or_create_by!(name: [non_combi_aircraft["name"], COMBI_SUFFIX].join(' '), bts_id: non_combi_aircraft["bts_id"], group: non_combi_aircraft["group"]).id
    else
      non_combi_aircraft["id"]
    end
  end

  def self.get_aircraft_id_from_group_and_partial_bts_id(group, partial_bts_id)
    bts_id = if partial_bts_id.to_i >= 10
      partial_bts_id.to_s
    elsif partial_bts_id.to_i < 100
      (partial_bts_id.to_i + 100).to_s[1..-1]
    else
      partial_bts_id.to_s[1..-1]
    end

    if group.to_i == 0
      bts_id
    else
      group.to_s + bts_id
    end
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

  def self.insert_file_data(file)
    aircraft = Aircraft.all.filter{|a| a.name.exclude?(COMBI_SUFFIX)}.map{ |a| {a.bts_id => a.attributes.slice("bts_id", "name", "group", "id")}}.reduce({}, :merge)
    airlines = Airline.all.pluck(:iata, :id).to_h
    airports = Airport.all.pluck(:iata, :id).to_h
    time_periods = TimePeriod.all.pluck(:name, :id).to_h

    records = []

    CSV.foreach(file, headers: false, col_sep: "|") do |d|
      if d[DATA_LOCATION[:departures_scheduled]].to_i > 0 && VALID_SERVICE_TYPES.include?(d[DATA_LOCATION[:service_type]])
        aircraft_id = self.get_aircraft_id(aircraft, d[DATA_LOCATION[:aircraft_group]], d[DATA_LOCATION[:aircraft_bts_id]], d[DATA_LOCATION[:aircraft_configuration_type]])
        airline_id = self.get_airline_id(airlines, d[DATA_LOCATION[:airline_iata]])
        origin_airport_id = self.get_airport_id(airports, d[DATA_LOCATION[:origin_iata]], d[DATA_LOCATION[:origin_name]])
        destination_airport_id = self.get_airport_id(airports, d[DATA_LOCATION[:destination_iata]], d[DATA_LOCATION[:destination_name]])
        time_period_id = self.get_time_period(time_periods, d[DATA_LOCATION[:month]], d[DATA_LOCATION[:year]])

        time = Time.now
        records << {
          aircraft_id: aircraft_id,
          airline_id: airline_id,
          origin_airport_id: origin_airport_id,
          destination_airport_id: destination_airport_id,
          time_period_id: time_period_id,
          departures_performed: d[DATA_LOCATION[:departures_performed]],
          departures_scheduled: d[DATA_LOCATION[:departures_scheduled]],
          seats: d[DATA_LOCATION[:seats]],
          passengers: d[DATA_LOCATION[:passengers]],
          created_at: time,
          updated_at: time,
        }
      end

      if records.length >= BATCH_SIZE
        tuples_to_check = records.map{ |r| [r[:aircraft_id], r[:airline_id], r[:origin_airport_id], r[:destination_airport_id], r[:time_period_id]]}
        bind_placeholders = Array.new(tuples_to_check.size, "(?, ?, ?, ?, ?)").join(", ")
        existing_records = Counts.where("(aircraft_id, airline_id, origin_airport_id, destination_airport_id, time_period_id) in (#{bind_placeholders})", *(tuples_to_check.flatten)).pluck(:aircraft_id, :airline_id, :origin_airport_id, :destination_airport_id, :time_period_id)
        records = records.filter{ |r| existing_records.exclude?([r[:aircraft_id], r[:airline_id], r[:origin_airport_id], r[:destination_airport_id], r[:time_period_id]]) }

        Counts.insert_all! records if records.length > 0
        records = []
      end
    end

    Counts.insert_all! records if records.length > 0
    ProcessedFile.create!(name: file)
  end

  def self.unfinished_files
    processed_files = ProcessedFile.pluck(:name)

    Dir.glob("data/bts/*").reject { |f| processed_files.include?(f) }
  end
end
