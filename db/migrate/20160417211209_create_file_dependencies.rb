class CreateFileDependencies < ActiveRecord::Migration
  def change
    create_table :file_dependencies do |t|
      t.integer :swift_file_id
      t.integer :dependency_id
      t.string :dependent_or_provider
      t.timestamps
    end
  end
end
