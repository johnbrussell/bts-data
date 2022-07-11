class CreateCounts < ActiveRecord::Migration[6.1]
  def up
    create_table :counts do |t|
      t.integer :aircraft_id, index: true, null: false
      t.integer :airline_id, index: true, null: false
      t.integer :origin_airport_id, index: true, null: false
      t.integer :destination_airport_id, index: true, null: false
      t.integer :time_period_id, index: true, null: false

      t.integer :departures_performed, null: false
      t.integer :departures_scheduled, null: false
      t.integer :seats, null: false
      t.integer :passengers, null: false

      t.timestamps
    end
  end

  def down
    drop_table :counts
  end
end
