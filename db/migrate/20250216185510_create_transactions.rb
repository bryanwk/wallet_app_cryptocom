class CreateTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table(:transactions) do |t|
      t.bigint :sender_id,            :null => true, :default => ""
      t.bigint :receiver_id,          :null => true, :default => ""
      t.decimal :amount,              :null => false, :default => ""
      t.string :transaction_type,     :null => false, :default => ""
      t.datetime :created_at,         :null => false, :default => ""
      t.datetime :updated_at,         :null => false, :default => ""
    end

    add_index(
      :transactions,
      :receiver_id,
      unique: false,
    )
    add_index(
      :transactions,
      :sender_id,
      unique: false,
    )
  end
end
