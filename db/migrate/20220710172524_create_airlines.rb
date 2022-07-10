class CreateAirlines < ActiveRecord::Migration[6.1]
  def up
    create_table :airlines do |t|
      t.string :iata, null: false, unique: true

      t.timestamps
    end
  end

  def down
    drop_table :airlines
  end
end
