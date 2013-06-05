class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.string :name
      t.string :email
      t.string :token
      t.string :payer_id
      t.datetime :paid_at
      t.string :description, :null => false
      t.decimal :amount, :precision => 8, :scale => 2, :null => false

      t.timestamps
    end
  end
end
