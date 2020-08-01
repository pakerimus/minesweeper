class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :bombs, null: false
      t.string :state, null: false
      t.integer :total_time, null: false, default: 0
      t.datetime :last_started_at

      t.timestamps
    end
  end
end
