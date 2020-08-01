class CreateCells < ActiveRecord::Migration[6.0]
  def change
    create_table :cells do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :row, null: false
      t.integer :column, null: false
      t.string :mark, null: false, default: 'no_mark'
      t.boolean :bomb, null: false, default: false
      t.boolean :cleared, null: false, default: false
      t.integer :adjacent_bombs, null: false, default: 0

      t.timestamps
    end
  end
end
