class TransactionsController < ApplicationController
  # Description: This controller is responsible for handling all the transactions
  #   such as deposit, withdraw, transfer, and transaction history.

  # Skipping CSRF token verification for API requests only for this project.
  skip_before_action :verify_authenticity_token

  # POST /users/:user_id/deposit
  def deposit
    # Check if the user exists
    if user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    result = DepositService.new(user, amount_in_float).call
    render_response(result)
  end

  # POST /users/:user_id/withdraw
  def withdraw
    # Check if the user exists
    if user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    result = WithdrawService.new(user, amount_in_float).call
    render_response(result)
  end

  # POST /users/:user_id/transfer
  def transfer
    # Check if the user exists
    if user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    # Check if the receiver exists
    if receiver_user.nil?
      render json: { error: 'Receiving user not found' }, status: :not_found
      return
    end

    result = TransferService.new(user, receiver_user, amount_in_float).call
    render_response(result)
  end

  # GET /users/:user_id/transactions
  def history
    # Check if the user exists
    if user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    # Fetch all transactions for the user
    transactions =
      Rails.cache.fetch("user_#{user.id}_transactions", expires_in: 1.hour) do
        Transaction.outgoing_only(user).
          or(Transaction.incoming_only(user)).
          includes(:sender, :receiver).
          order(created_at: :desc)
      end

    # Format the transactions for the response
    formatted_transactions = transactions.map do |transaction|
      transfer_type = nil
      recipient = nil

      # Check if the transaction is a transfer
      if transaction.transaction_type === Transaction::Type::Enum::TRANSFER
        # Determine if the transaction is incoming or outgoing
        transfer_type = transaction.receiver == user ? Transaction::Transfer::Type::Enum::INCOMING : Transaction::Transfer::Type::Enum::OUTGOING
        # Determine the recipient
        recipient = transaction.receiver == user ? transaction.sender : transaction.receiver
      end

      {
        id: transaction.id,
        transaction_type: transaction.transaction_type,
        transfer_type: transfer_type,
        amount: transaction.amount,
        timestamp: transaction.created_at,
        recipient: recipient.nil? ? nil : { id: recipient.id, name: recipient.name }
      }
    end

    render json: formatted_transactions
  end

  private

  def amount_in_float
    amount_from_params.to_f
  end

  def amount_from_params
    params.require(:amount)
  end

  def user
    if user_id_from_params.present?
      # Avoid using .find() as it raises an exception if the record is not found
      User.find_by(id: user_id_from_params)
    end
  end

  def receiver_user
    if receiver_user_id_from_params.present?
      # Avoid using .find() as it raises an exception if the record is not found
      User.find_by(id: receiver_user_id_from_params)
    else
      render json: { error: 'Invalid receiver_id params' }, status: :not_found
    end
  end

  def user_id_from_params
    params[:user_id]
  end

  def receiver_user_id_from_params
    params[:receiver_id]
  end

  def render_response(result)
    if result[:success]
      render json: { message: 'Operation successful', transaction: result[:transaction] }
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
end
