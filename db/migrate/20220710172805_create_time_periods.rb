class CreateTimePeriods < ActiveRecord::Migration[6.1]
  def up
    create_table :time_periods do |t|
      t.string :name, null: false, unique: true
      t.integer :year, null: false
      t.integer :month, null: false

      t.timestamps
    end
  end

  def down
    drop_table :time_periods
  end
end
