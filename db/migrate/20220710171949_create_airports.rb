class CreateAirports < ActiveRecord::Migration[6.1]
  def up
    create_table :airports do |t|
      t.string :name, null: false
      t.string :iata, null: false, unique: true

      t.timestamps
    end
  end

  def down
    drop_table :airports
  end
end
