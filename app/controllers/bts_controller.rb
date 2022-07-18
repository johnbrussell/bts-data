class BtsController < ApplicationController
  def index
    @airlines = Airline.select_options
    @airports = Airport.select_options
    @aircraft = Aircraft.select_options
  end

  def show
    @start_year = params[:from_year]
    @start_month = params[:from_month]
    @end_year = params[:end_year]
    @end_month = params[:end_month]
    @airline = if params[:airline].present? then Airline.find(params[:airline]) else nil end
    @departure_airport = if params[:departure_airport].present? then Airport.find(params[:departure_airport]) else nil end
    @arrival_airport = if params[:arrival_airport].present? then Airport.find(params[:arrival_airport]) else nil end
    @aircraft_type = if params[:aircraft_type].present? then Aircraft.find(params[:aircraft_type]) else nil end
    @filter_for_weekly = params[:filter_for_weekly] == "1"
    @exclude_covid = params[:exclude_covid] == "1"

    @airlines = Airline.select_options
    @airports = Airport.select_options
    @aircraft = Aircraft.select_options

    @groups = []
    if params[:group_by_departure_airport] == "1" then @groups << "origin_airport.iata" end
    if params[:group_by_arrival_airport] == "1" then @groups << "destination_airport.iata" end
    if params[:group_by_time_period] == "1" then @groups << "time_periods.name" end
    if params[:group_by_airline] == "1" then @groups << "airlines.iata" end
    if params[:group_by_aircraft] == "1" then @groups << "aircraft.name" end

    @results = Counts.meeting_specific_criteria(@start_month, @start_year, @end_month, @end_year, @airline&.id, @aircraft_type&.id, @departure_airport&.id, @arrival_airport&.id, @groups, @filter_for_weekly, @exclude_covid)
  end
end
