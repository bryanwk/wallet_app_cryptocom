# frozen_string_literal: true

class Wallet < ApplicationRecord
  after_update :invalidate_wallet_cache

  belongs_to :user
  has_many :transactions, through: :user

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  private

  def invalidate_wallet_cache
    # Invalidate the cache for the user's wallet
    Rails.cache.delete("user_#{user_id}_balance")
  end
end
