class CreateTrials < ActiveRecord::Migration
  def change
    create_table :trials do |t|
      t.datetime :date
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end
end
