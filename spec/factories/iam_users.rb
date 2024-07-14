FactoryBot.define do
  factory :iam_user, class: 'Iam::Models::User' do
    email { 'jane@betterfinance.co' }
    password { 'securePassword123!' }
  end
end
