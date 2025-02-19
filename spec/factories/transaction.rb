FactoryBot.define do
  factory :transaction do
    sender { nil }
    receiver { create(:user) }
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    transaction_type { %w[deposit withdrawal transfer].sample }
  end
end