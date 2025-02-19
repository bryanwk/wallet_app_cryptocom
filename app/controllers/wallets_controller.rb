class WalletsController < ApplicationController

  # GET /users/:user_id/balance
  def balance
    # Check if the user exists
    if user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    balance = Rails.cache.fetch("user_#{user.id}_balance", expires_in: 1.hour) do
      user.wallet.balance
    end

    render json: { balance: balance }
  end

  private

  def user
    if user_id_from_params.present?
      # Avoid using .find() as it raises an exception if the record is not found
      User.find_by(id: user_id_from_params)
    end
  end

  def user_id_from_params
    params[:user_id]
  end
end
