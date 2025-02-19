class TransferService
  # This service is responsible for transferring money from one user to another.
  # Initialize sender, receiver, and amount
  def initialize(user, receiver, amount)
    @user = user
    @receiver = receiver
    @amount = amount
  end

  def call
    # Check if the amount is valid
    return { success: false, error: 'Invalid amount' } unless amount_valid?
    # Check if the balance is sufficient
    return { success: false, error: 'Insufficient amount' } unless balance_sufficient
    # Check if the sender and receiver are the same
    return { success: false, error: 'Sender and receiver cannot be the same' } if @user == @receiver

    transaction_record = nil

    ActiveRecord::Base.transaction do
      # Lock the wallets to prevent race conditions
      @user.wallet.lock!
      @receiver.wallet.lock!
      @user.wallet.update!(balance: @user.wallet.balance - @amount)
      @receiver.wallet.update!(balance: @receiver.wallet.balance + @amount)

      # Create a transaction record for the transfer
      transaction_record = Transaction.create!(
        sender: @user,
        receiver: @receiver,
        amount: @amount,
        transaction_type: Transaction::Type::Enum::TRANSFER
      )
    end
    { success: true, transaction: transaction_record}
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