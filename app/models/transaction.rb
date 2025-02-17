# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :receiver, class_name: 'User', optional: true

  validates :amount, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true
  validate :validate_transfer

  private

  def validate_transfer
    if transaction_type == 'transfer' && sender_id == receiver_id
      errors.add(:base, 'Sender and receiver cannot be the same')
    end
  end
end
