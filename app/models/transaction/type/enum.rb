# frozen_string_literal: true

module ::Transaction::Type
  module Enum
    TRANSFER      = "transfer"
    DEPOSIT       = "deposit"
    WITHDRAWAL    = "withdrawal"

    def self.all
      constants(false).map do |const_name|
        const_get(const_name)
      end
    end
  end
end
