class CreateDependencies < ActiveRecord::Migration
  def change
    create_table :dependencies do |t|
      t.string :value
      t.string :dependency_type

      t.timestamps
    end
  end
end
