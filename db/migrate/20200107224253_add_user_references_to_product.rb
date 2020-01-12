class AddUserReferencesToProduct < ActiveRecord::Migration[6.0]
  def change
    add_reference :products, :user, null: true, foreign_key: true
  end
end
