class WithdrawService
  # This service is responsible for withdrawing money from a user's wallet.
  # Initialize user and amount
  def initialize(user, amount)
    @user = user
    @amount = amount
  end

  def call
    # Check if the amount is valid
    return { success: false, error: 'Invalid amount' } unless amount_valid?
    # Check if the balance is sufficient
    return { success: false, error: 'Insufficient amount' } unless balance_sufficient

    transaction_record = nil

    ActiveRecord::Base.transaction do
      # Lock the wallet to prevent race conditions
      @user.wallet.lock!
      @user.wallet.update!(balance: @user.wallet.balance - @amount)

      # Create a transaction record for the withdrawal
      transaction_record = Transaction.create!(
        sender: @user,
        receiver: nil,
        amount: @amount,
        transaction_type: Transaction::Type::Enum::WITHDRAWAL
      )
    end

    { success: true, transaction: transaction_record }
  rescue ActiveRecord::Rollback => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  end

  def amount_valid?
    @amount > 0
  end

  def balance_sufficient
    @amount <= @user.wallet.balance
  end
end