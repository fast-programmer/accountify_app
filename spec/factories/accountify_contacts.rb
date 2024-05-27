FactoryBot.define do
  factory :accountify_contact, class: 'Accountify::Models::Contact' do
    iam_tenant_id { 4 }
    first_name { "John" }
    last_name { "Smith" }
    email { "john.smith@coolbincompany.org" }
  end
end
