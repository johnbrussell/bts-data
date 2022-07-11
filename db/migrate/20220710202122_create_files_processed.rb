class CreateFilesProcessed < ActiveRecord::Migration[6.1]
  def up
    create_table :files_processed do |t|
      t.string :name, null: false
      
      t.timestamps
    end
  end

  def down
    drop_table :files_processed
  end
end
