class CreateSwiftFiles < ActiveRecord::Migration
  def change
    create_table :swift_files do |t|
      t.string :filename
      t.timestamps
    end
  end
end
