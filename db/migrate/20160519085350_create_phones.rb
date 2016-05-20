class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.integer :row_id, null: false

      t.string :number

      t.timestamps null: false
    end

    add_index :phones, [:row_id]
    add_index :phones, [:number]
  end
end
