# frozen_string_literal: true

class User < ApplicationRecord
  include WithTransactions
  include WithWallet

  validates :name, presence: true
  validates :email, uniqueness: true

  after_create :create_wallet

  private

  def create_wallet
    Wallet.create(user: self, balance: 0.0)
  end
end
