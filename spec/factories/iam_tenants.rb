FactoryBot.define do
  factory :iam_tenant, class: 'Iam::Models::Tenant' do
    subdomain { 'betterfinance' }
  end
end
