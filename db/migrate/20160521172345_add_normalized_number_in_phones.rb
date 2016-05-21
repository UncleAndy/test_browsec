class AddNormalizedNumberInPhones < ActiveRecord::Migration
  def change
    add_column :phones, :normalized, :string
  end
end
