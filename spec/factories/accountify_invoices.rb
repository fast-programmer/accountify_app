FactoryBot.define do
  factory :accountify_invoices, class: 'Accountify::Models::Invoice' do
    iam_tenant_id { 4 }
    first_name { "John" }
    last_name { "Smith" }
    email { "john.smith@coolbincompany.org" }
  end
end
