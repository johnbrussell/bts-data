class CreateAircraft < ActiveRecord::Migration[6.1]
  def up
    create_table :aircraft do |t|
      t.string :name, null: false
      t.integer :bts_id, null: false
      t.integer :group, null: false

      t.timestamps
    end
  end

  def down
    drop_table :aircraft
  end
end
