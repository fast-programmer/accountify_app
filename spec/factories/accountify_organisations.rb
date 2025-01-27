FactoryBot.define do
  factory :accountify_organisation, class: 'Accountify::Organisation' do
    tenant_id { 4 }
    name { "Cool Bin Company" }
  end
end
