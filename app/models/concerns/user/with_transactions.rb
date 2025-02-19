class User < ApplicationRecord
  module WithTransactions
    extend ActiveSupport::Concern
    included do
      has_many :sent_transactions, class_name: "Transaction", foreign_key: "sender_id"
      has_many :received_transactions, class_name: "Transaction", foreign_key: "receiver_id"
    end
  end
end
