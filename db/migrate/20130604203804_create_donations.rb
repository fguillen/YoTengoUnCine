class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.string :name
      t.string :email
      t.string :token
      t.string :payer_id
      t.datetime :paid_at
      t.datetime :confirmed_at
      t.string :description, :null => false
      t.decimal :amount, :precision => 8, :scale => 2, :null => false
      t.string :kind, :null => false
      t.string :transaction_id
      t.string :chair_name

      t.string :payer_email
      t.string :payer_address_street
      t.string :payer_address_zip
      t.string :payer_name
      t.string :payer_address_country_code
      t.string :payer_address_name
      t.string :payer_address_country
      t.string :payer_address_city
      t.string :payer_address_state

      t.timestamps
    end
  end
end
