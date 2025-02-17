class CreateWallets < ActiveRecord::Migration[4.2]
  def change
    create_table(:wallets) do |t|
      t.bigint :user_id,              :null => false, :default => ""
      t.decimal :balance,             :null => false, :default => ""
      t.datetime :created_at,         :null => false, :default => ""
      t.datetime :updated_at,         :null => false, :default => ""
    end

    add_index(
      :wallets,
      :user_id,
      :unique => true
    )
  end
end
