FactoryBot.define do
  factory :accountify_invoice_line_item, class: 'Accountify::Models::Invoice::LineItem' do
    description { 'Chair' }
    unit_amount_amount { BigDecimal('100.00') }
    unit_amount_currency_code { 'AUD' }
  end
end
