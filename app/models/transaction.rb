# frozen_string_literal: true

class Transaction < ApplicationRecord
  after_create :invalidate_transaction_cache
  after_create :update_wallet

  belongs_to :sender, class_name: "User", optional: true
  belongs_to :receiver, class_name: "User", optional: true

  validates :amount, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true

  class << self
    def outgoing_only(sender)
      where(sender_id: sender)
    end

    def incoming_only(receiver)
      where(receiver_id: receiver)
    end
  end

  private

  def update_wallet
    # Update Sender User wallet balance
    if sender_id.present?
      sender.wallet.update!(balance: sender.wallet.balance - amount)
    end

    # Update Receiver User wallet balance
    if receiver_id.present?
      receiver.wallet.update!(balance: receiver.wallet.balance + amount)
    end
  end

  def invalidate_transaction_cache
    # Invalidate the cache for the user's transactions
    if sender_id.present?
      Rails.cache.delete("user_#{sender_id}_transactions")
    end

    # Invalidate the cache for the recipient's transactions
    if receiver_id.present?
      Rails.cache.delete("user_#{receiver_id}_transactions")
    end
  end
end
