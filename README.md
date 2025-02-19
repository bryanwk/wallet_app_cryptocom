# README

Wallet Apps for crypto.com Coding Test

This backend app is implemented using Ruby on Rails.
The simple wallet app allows basic transaction functionalities such as:
- Deposit money
- Withdraw money
- Transfer money to other user
- View user balance
- View transaction history

## How to Set Up and Run the Code

Prerequisites

- Ruby 3.x
- Rails 7.x
- PostgreSQL
- Git
- Bundler
- Redis

### App & DB Setup

Assuming all the above prerequisites are available, you can proceed to the below steps:

Clone Github Repository
- `git clone https://github.com/bryanwk/wallet_app_cryptocom.git`

Navigate inside the folder
- `cd wallet_app_cryptocom`

Update config/database.yml with your PostgreSQL credentials.
- `config/database.yml`

Database setup
- `rails db:create` or `rake db:create`
- `rails db:migrate` or `rake db:migrate`
I have also set up some db seeds to populate the database (optional)
- `rails db:seed` or `rake db:seed`

Install bundle
- `bundle install`

Run the server
- `rails server`

Voila! App has started running on your localhost

### Test Setup
Run test
- `bundle exec rspec`

## How to Review the Code

1. Review User, Wallet, and Transaction models for associations and validations.
   1. User Model ~ `app/models/user.rb`
   2. Wallet Model ~ `app/models/wallet.rb`
   3. Transaction Model ~ `app/models/transaction.rb`

2. Review and Test the Controllers:
   1. WalletsController ~ `app/controllers/wallets_controller.rb`
      - Contains API calling function for view user balance
      - View User Balance API - `curl -X POST http://localhost:3000/users/1/balance`
   2. TransactionsController ~ `app/controllers/transactions_controller.rb`
      - Contains API calling function for deposit, withdraw, transfer, and view transactions history
      - Deposit Money to User API - `curl -X POST http://localhost:3000/users/1/deposit?amount=1000`
      - Withdraw Money to User API - `curl -X POST http://localhost:3000/users/1/withdraw?amount=1000`
      - Transfer Money to Another User API - `curl -X POST http://localhost:3000/users/1/transfer?amount=100&receiver_id=2`
      - View Transaction History API - `curl -X GET http://localhost:3000/users/1/transactions`

3. Review the Services:
   1. DepositService ~ `app/services/deposit_service.rb`
      - Contains deposit logic and transaction handling
   2. WithdrawService ~ `app/services/withdraw_service.rb`
      - Contains withdrawal logic and transaction handling
   3. TransferService ~ `app/services/transfer_service.rb`
      - Contains transfer logic and transaction handling

4. Review the Tests:
   1. Run spec file using `bundle exec rspec`
   2. Wallet Controller Spec ~ `spec/controllers/wallets_controller_spec.rb`
      - Contains quality test for functions within WalletsController, including validations, success response, and cache test
   3. Transaction Controller Spec ~ `spec/controllers/transactions_controller_spec.rb`
      - Contains quality test for functions within TransactionsController, including validations, success response, and cache test

5. Look for Best Practices:
   - This project utilizes RESTful conventions, DRY principles, and clean code practices.
   - Redis is used for caching, reducing load time.
   - Comprehensive API test using RSpec
   - Detailed validation
   - Code Readability following Ruby guidelines and clear documentation and comments

## Design Decisions

1. Ruby on Rails
   - Using RoR to its simplicities and strong capabilities
   - Strong library support, future-proof
   - ActiveRecord for seamless DB interactions and validations
   - I'm more proficient in RoR

2. Redis for Caching
   - Performance: Redis is an in-memory data store, making it extremely fast for read-heavy operations like fetching transaction history.
   - Scalability: Redis can handle large datasets and high traffic, making it suitable for production environments.
   - Expiration: Redis supports key expiration, which is useful for caching data for a specific duration (e.g., 1 hour for transaction history).
   - Impelentation, for example in caching Transaction History is a great benefit to reduce database load and improve response time. Cache expires after 1 hour, assuming that the traffic might be large.
  
3. Use of Services
   - Separation of Concern, encapsulating business logic and keeping controllers as thin as possible, focusing on handling HTTP request.
   - Reusability, if deposit, withdrawal, transfer were to be used elsewhere in the app.
   - Easier to test in isolation

4. ActiveRecord Transactions with Locks on transactions operations
   - Maintain data integrity, ensuring database operations either all succeed or all fail
   - Concurrency Control, prevent race conditions when multiple request try to update at the same time.
   - Due to the data sensitivity of money, this is highly important to utilize.

## Areas to Improve

1. Authentication and Authorization
   - Add user authentication to restrict access to sensitive endpoints.
   - This is not outlined in the requirements but should be first priority to be added.
  
2. Pagination
   - User's transaction history can be a large dataset
   - Pagination will handle large responses efficiently

3. Improve Caching
   - Add response caching, cache invalidation, and conditional caching.

4. Helpful Parameters
   - Improvements such as adding `earliest_created_time_limit` and `latest_created_time_limit` could also improve data filtering for transaction history.

5. Expand test coverage beyond controllers
   - Add tests in Model and Services
   - This could also be expanded for Job and Helper tests (if needed)
   - Introduce performance and security tests

6. Rate Limiting
   - Implement rate limiting to prevent abuse of the API.

## Functional and Non-Functional Requirements

### Functional Requirements

1. View Balance
   - Users can view their current balance
  
2. Deposit Funds
   - Users can deposit funds into their wallet.
  
3. Withdraw Funds
   - Users can withdraw funds from their wallet.

4. Transfer Funds
   - Users can transfer funds to other users.
  
5. View Transaction History
   - Users can view their transaction history, including deposits, withdrawals, and transfers.

## Non-Functional Requirements

1. Performance
   - Caching is used to improve response times for frequently accessed data.

2. Reliability
   - Transactions are handled securely to avoid mistakes

3. Scalability:
   - The solution is designed to handle a growing number of users and transactions. Although, improvements can still be made.

4. Maintainability:
   - The code is clean, modular, well-documented, and follows best practices.

## Features Chosen Not to Include

1. User Authentication and Authorization
   - Adding JWT, OAuth authentication and role-based authorization could be introduced in the assessment.
   - However, since the primary goal was to focus on functionality, I chose not to include authentication as it would have introduced additional complexity and required more time.

2. Pagination
   - The current implementation returns all transactions for a user, which is sufficient for small datasets.

## Best Practices

Mentioned in the above section

## Simplicity

- Minimal dependencies is used
- Logical structure in utilizing RoR's MVC architecture
- Straightforward logic

## Time Spent

Total Time: Approx. 7 hours. (Spread over 72 hours)

Design and Setup: 1 hour.

Implementation: 4 hours.

Testing and Debugging: 2 hours.
