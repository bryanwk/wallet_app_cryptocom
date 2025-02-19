# frozen_string_literal: true

module ::Transaction::Transfer::Type
  module Enum
    OUTGOING      = "outgoing"
    INCOMING      = "incoming"

    def self.all
      constants(false).map do |const_name|
        const_get(const_name)
      end
    end
  end
end
