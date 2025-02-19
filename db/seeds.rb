# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Create Users
user1 = User.create!(name: 'Alice', email: 'alice@example.com')
user2 = User.create!(name: 'Bob', email: 'bob@example.com')

# Create Transactions
Transaction.create!(sender: nil, receiver: user1, amount: 1000.0, transaction_type: 'deposit')
Transaction.create!(sender: nil, receiver: user2, amount: 100.0, transaction_type: 'withdrawal')
Transaction.create!(sender: user1, receiver: user2, amount: 200.0, transaction_type: 'transfer')
Transaction.create!(sender: user2, receiver: user1, amount: 300.0, transaction_type: 'transfer')

puts 'Database seeded successfully!'
