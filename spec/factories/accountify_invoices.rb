FactoryBot.define do
  factory :accountify_invoice, class: 'Accountify::Models::Invoice' do
    tenant_id { 4 }
    currency_code { "AUD" }
    due_date { Date.today + 30.days }
    sub_total_amount { BigDecimal("100.00") }
    sub_total_currency_code { "AUD" }

    trait :draft do
      status { "draft" }
    end

    trait :approved do
      status { "approved" }
    end

    trait :awaiting_payment do
      status { "awaiting payment" }
    end

    trait :paid do
      status { "paid" }
    end

    trait :voided do
      status { "voided" }
    end
  end
end
