class User < ApplicationRecord
  module WithWallet
    extend ActiveSupport::Concern
    included do
      has_one :wallet, dependent: :destroy
    end
  end
end
