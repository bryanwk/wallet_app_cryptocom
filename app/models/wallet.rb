# frozen_string_literal: true

class Wallet < ApplicationRecord
  belongs_to :user
  has_many :transactions, through: :user

  validates :balance, numericality: { greater_than_or_equal_to: 0 }
end
