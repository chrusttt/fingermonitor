class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.float :grade
      t.datetime :date
      t.integer :trial_id

      t.timestamps
    end
  end
end
