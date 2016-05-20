class CreateRows < ActiveRecord::Migration
  def change
    create_table :rows do |t|
      t.integer :user_id, null: false

      t.string :name, null: false
      t.string :avatar
      t.string :context

      t.timestamps null: false
    end

    add_index :rows, [:user_id, :name]
    add_index :rows, [:user_id, :context]
  end
end
