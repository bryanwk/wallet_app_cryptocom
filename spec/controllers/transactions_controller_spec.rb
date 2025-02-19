require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:user) { create(:user) }
  let(:wallet) { user.wallet }

  describe 'POST /users/:user_id/deposit' do
    subject { call_action }

    let(:call_action) { post :deposit, params: params }
    let(:params) {
      {
        user_id: user.id,
        amount: 1000.0
      }
    }

    context 'when user exists' do
      it 'returns successful transaction record' do
        initial_balance = wallet.balance
        call_action

        expect(response).to have_http_status(:ok)
        expect(json_response['transaction']['amount'].to_f).to eq(1000.0)

        wallet.reload
        expect(wallet.balance).to eq(initial_balance + 1000.0)
      end

      context 'when amount is invalid' do
        before { params[:amount] = -1000.0 }

        it 'returns an unprocessable entity error' do
          call_action

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user does not exist' do
      before { params[:user_id] = -1 }

      it 'returns a not found error' do
        call_action
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /users/:user_id/withdraw' do
    subject { call_action }

    let(:call_action) { post :withdraw, params: params }
    let(:params) {
      {
        user_id: user.id,
        amount: 1000.0
      }
    }

    before do
      wallet.update!(balance: 1000.0)
    end

    context 'when user exists' do
      it 'returns successful transaction record' do
        initial_balance = wallet.balance
        call_action

        expect(response).to have_http_status(:ok)
        expect(json_response['transaction']['amount'].to_f).to eq(1000.0)

        wallet.reload
        expect(wallet.balance).to eq(initial_balance - 1000.0)
      end

      context 'when amount is invalid' do
        before { params[:amount] = -1000.0 }

        it 'returns an unprocessable entity error' do
          call_action

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when balance is insufficient' do
        before { params[:amount] = 2000.0 }

        it 'returns an unprocessable entity error' do
          call_action

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user does not exist' do
      before { params[:user_id] = -1 }

      it 'returns a not found error' do
        call_action
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /users/:user_id/transfer' do
    subject { call_action }

    let(:receiver_user) { create(:user) }
    let(:receiver_wallet) { receiver_user.wallet }

    let(:call_action) { post :transfer, params: params }
    let(:params) {
      {
        user_id: user.id,
        receiver_id: receiver_user.id,
        amount: 1000.0
      }
    }

    before do
      wallet.update!(balance: 1000.0)
    end

    context 'when user and receiver exists' do
      context 'when user and receiver is different' do
        it 'returns successful transaction record' do
          initial_sender_balance = wallet.balance
          initial_receiver_balance = receiver_wallet.balance

          call_action

          expect(response).to have_http_status(:ok)
          expect(json_response['transaction']['amount'].to_f).to eq(1000.0)

          wallet.reload
          receiver_wallet.reload
          expect(wallet.balance).to eq(initial_sender_balance - 1000.0)
          expect(receiver_wallet.balance).to eq(initial_receiver_balance + 1000.0)
        end
      end

      context 'when user and receiver is the same' do
        before { params[:receiver_id] = user.id }

        it 'returns an unprocessable entity error' do
          call_action

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when amount is invalid' do
        before { params[:amount] = -1000.0 }

        it 'returns an unprocessable entity error' do
          call_action

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when balance is insufficient' do
        before { params[:amount] = 2000.0 }

        it 'handles invalid amount correctly' do
          call_action

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when sender and/or receiver does not exist' do
      before { params[:user_id] = -1 }

      it 'returns a not found error' do
        call_action
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /users/:user_id/transactions' do
    subject { call_action }

    let(:other_user) { create(:user) }

    let(:call_action) { get :history, params: params }
    let(:params) { { user_id: user.id } }

    context 'when user exists' do
      context 'when there are zero transactions' do
        it 'handles zero transactions correctly' do
          call_action

          expect(response).to have_http_status(:ok)
          expect(json_response.size).to eq(0)
        end
      end

      context 'when there are transactions' do
        before do
          # Create some transactions for the user
          create(:transaction, sender: nil, receiver: user, amount: 1000.0, transaction_type: Transaction::Type::Enum::DEPOSIT)
          create(:transaction, sender: user, receiver: nil, amount: 100.0, transaction_type: Transaction::Type::Enum::WITHDRAWAL)
          create(:transaction, sender: user, receiver: other_user, amount: 300.0, transaction_type: Transaction::Type::Enum::TRANSFER)
          create(:transaction, sender: other_user, receiver: user, amount: 200.0, transaction_type: Transaction::Type::Enum::TRANSFER)
        end

        it 'returns the transaction history' do
          call_action

          expect(response).to have_http_status(:ok)
          expect(json_response.size).to eq(4)

          # Check the first transaction (deposit)
          deposit_transaction = json_response.find { |t| t['transaction_type'] == Transaction::Type::Enum::DEPOSIT }
          expect(deposit_transaction['amount'].to_f).to eq(1000.0)
          expect(deposit_transaction['transfer_type']).to be_nil
          expect(deposit_transaction['recipient']).to be_nil

          # Check the second transaction (withdrawal)
          withdrawal_transaction = json_response.find { |t| t['transaction_type'] == Transaction::Type::Enum::WITHDRAWAL }
          expect(withdrawal_transaction['amount'].to_f).to eq(100.0)
          expect(withdrawal_transaction['transfer_type']).to be_nil
          expect(withdrawal_transaction['recipient']).to be_nil

          # Check the second transaction (outgoing transfer)
          outgoing_transfer = json_response.find { |t| t['transaction_type'] == Transaction::Type::Enum::TRANSFER && t['transfer_type'] == Transaction::Transfer::Type::Enum::OUTGOING }
          expect(outgoing_transfer['amount'].to_f).to eq(300.0)
          expect(outgoing_transfer['recipient']['id']).to eq(other_user.id)
          expect(outgoing_transfer['recipient']['name']).to eq(other_user.name)

          # Check the third transaction (incoming transfer)
          incoming_transfer = json_response.find { |t| t['transaction_type'] == Transaction::Type::Enum::TRANSFER && t['transfer_type'] == Transaction::Transfer::Type::Enum::INCOMING }
          expect(incoming_transfer['amount'].to_f).to eq(200.0)
          expect(incoming_transfer['recipient']['id']).to eq(other_user.id)
          expect(incoming_transfer['recipient']['name']).to eq(other_user.name)
        end

        it 'caches the transaction history for 1 hour' do
          # First request to prime the cache
          call_action
          expect(response).to have_http_status(:ok)

          # Verify the cache is set
          cache_key = "user_#{user.id}_transactions"
          expect(Rails.cache.exist?(cache_key)).to be true

          # Second request within the cache expiry time
          call_action
          expect(response).to have_http_status(:ok)
          expect(json_response.size).to eq(4)
        end

        it 'expires cache after 1 hour' do
          # First request to prime the cache
          call_action
          initial_cache = Rails.cache.read("user_#{user.id}_transactions")

          # Simulate cache expiry by traveling 61 minutes into the future
          Timecop.travel(61.minutes.from_now) do
            call_action
            new_cache = Rails.cache.read("user_#{user.id}_transactions")
            expect(new_cache).not_to eq(initial_cache)
          end
        end
      end
    end

    context 'when user does not exist' do
      before { params[:user_id] = -1 }

      it 'returns a not found error' do
        call_action
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('User not found')
      end
    end
  end

  private

  # Helper method to parse JSON response
  def json_response
    JSON.parse(response.body)
  end
end
