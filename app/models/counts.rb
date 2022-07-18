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

  def self.meeting_specific_criteria(start_month, start_year, end_month, end_year, airline, aircraft, origin_airport, destination_airport, groups, filter_for_weekly, exclude_covid, exclude_freight)
    start_time = if start_year.present? && start_month.present? then (start_year.to_i * 100 + start_month.to_i).to_s else nil end
    end_time = if end_year.present? && end_month.present? then (end_year.to_i * 100 + end_month.to_i).to_s else nil end

    query = Counts
      .joins(:time_period)
      .joins(:airline)
      .joins("INNER JOIN airports AS origin_airport on counts.origin_airport_id == origin_airport.id")
      .joins("INNER JOIN airports AS destination_airport on counts.destination_airport_id == destination_airport.id")
      .joins(:aircraft)

    if start_time.present?
      query = query.where("time_periods.name >= ?", start_time)
    end

    if end_time.present?
      query = query.where("time_periods.name <= ?", end_time)
    end

    if airline.present?
      query = query.where(airline_id: airline)
    end

    if aircraft.present?
      query = query.where(aircraft_id: aircraft)
    end

    if origin_airport.present?
      query = query.where(origin_airport_id: origin_airport)
    end

    if destination_airport.present?
      query = query.where(destination_airport_id: destination_airport)
    end

    if exclude_covid
      covid = (202003..202105).to_a.map(&:to_s)
      query = query.where("time_periods.name NOT IN (?)", covid)
    end

    if exclude_freight
      query = query.where("seats > 0")
    end

    group_ases = groups.map { |g| g.gsub('.', '_') }
    selections = groups.zip(group_ases).map { |a| a.join(' AS ') }

    if groups.any?
      query = query.group(*groups).order(*groups)

      if filter_for_weekly
        query = query.having("sum(departures_scheduled) >= 4")
      end
    end

    query
      .select(*(selections + ["sum(departures_scheduled) AS total_departures_scheduled", "sum(departures_performed) AS total_departures_performed", "sum(seats) AS total_seats", "sum(passengers) AS total_passengers"]))
  end

  def display(groups)
    route = if groups.include?("origin_airport.iata") || groups.include?("destination_airport.iata") then "#{origin_airport_iata}-#{destination_airport_iata}: " else "" end
    time_period = if groups.include?("time_periods.name") then "#{time_periods_name}: " else "" end
    airline = if groups.include?("airlines.iata") then "#{airlines_iata}: " else "" end
    aircraft = if groups.include?("aircraft.name") then "#{aircraft_name}: " else "" end

    "#{route}#{time_period}#{airline}#{aircraft}#{total_departures_scheduled} departures scheduled, #{total_departures_performed} departures performed (#{(total_departures_performed.to_f / total_departures_scheduled * 100).round(1)}%), #{total_seats} seats, #{total_passengers} passengers (#{(total_passengers.to_f / total_seats * 100).round(1)}%)"
  end
end
