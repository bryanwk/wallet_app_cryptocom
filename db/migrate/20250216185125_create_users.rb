class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table(:users) do |t|
      t.string :name, null: false, default: ""
      t.string :email, null: false, default: ""
      t.datetime :created_at, null: false, default: ""
      t.datetime :updated_at, null: false, default: ""
      t.string :authentication_token, null: false, default: ""
    end
  end
end
