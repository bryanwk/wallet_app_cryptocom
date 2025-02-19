# frozen_string_literal: true

class Transaction < ApplicationRecord
  after_create :invalidate_transaction_cache

  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :receiver, class_name: 'User', optional: true

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
