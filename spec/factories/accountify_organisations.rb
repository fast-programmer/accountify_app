FactoryBot.define do
  factory :accountify_organisation, class: 'Accountify::Models::Organisation' do
    iam_tenant_id { 4 }
    name { "Cool Bin Company" }
  end
end
