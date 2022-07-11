class CreateProcessedFiles < ActiveRecord::Migration[6.1]
  def up
    create_table :processed_files do |t|
      t.string :name, null: false

      t.timestamps
    end
  end

  def down
    drop_table :processed_files
  end
end
