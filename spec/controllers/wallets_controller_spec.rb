require 'rails_helper'

RSpec.describe WalletsController, type: :controller do
  let(:user) { create(:user) }
  let(:wallet) { user.wallet }

  before do
    wallet.update!(balance: 100.0)
  end

  describe 'GET /users/:user_id/balance' do
    subject { call_action }

    let(:call_action) { get :balance, params: params }
    let(:params) { { user_id: user.id } }

    context 'when user exists' do
      it 'returns the wallet balance' do
        call_action
        expect(response).to have_http_status(:ok)
        # Parse the JSON response and check the balance
        expect(json_response['balance'].to_f).to eq(wallet.balance)
      end

      it "caches the balance response for 1 hour" do
        # First request to prime the cache
        call_action
        expect(response).to have_http_status(:ok)
        initial_balance = json_response['balance'].to_f

        # Verify the cache is set
        cache_key = "user_#{user.id}_balance"
        expect(Rails.cache.exist?(cache_key)).to be true
        expect(Rails.cache.read(cache_key).to_f).to eq(initial_balance)

        # Second request within the cache expiry time
        call_action
        expect(response).to have_http_status(:ok)
        expect(json_response['balance'].to_f).to eq(initial_balance)
      end

      it 'handles zero balance correctly' do
        # Update the wallet balance to zero
        wallet.update!(balance: 0.0)
        call_action

        expect(response).to have_http_status(:ok)
        # Parse the JSON response and check the balance
        expect(json_response['balance'].to_f).to eq(0.0)
      end
    end

    context 'when user does not exist' do
      # Set an invalid user_id
      before { params[:user_id] = -1 }

      it 'returns a not found error' do
        call_action
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'cache expiration' do
      it 'expires cache after 1 hour' do
        call_action
        initial_cache = Rails.cache.read("user_#{user.id}_balance")

        # Simulate when cache expires
        Timecop.travel(61.minutes.from_now) do
          call_action
          new_cache = Rails.cache.read("user_#{user.id}_balance")
          expect(new_cache).not_to eq(initial_cache)
        end
      end
    end
  end

  private

  # Helper method to parse JSON response
  def json_response
    JSON.parse(response.body)
  end
end
