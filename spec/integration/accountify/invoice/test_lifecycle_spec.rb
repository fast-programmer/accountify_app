require 'rails_helper'

RSpec.describe 'Invoice Lifecycle', type: :integration do
  it 'transitions as expected' do
    Sidekiq::Testing.disable!

    begin
      load Rails.root.join('script/accountify/invoice/test_lifecycle.rb')

      expect(Accountify::Models::Organisation.count).to eq(1)
      expect(Accountify::Models::Contact.count).to eq(1)
      expect(Accountify::Models::Invoice.count).to eq(1)
    ensure
      Sidekiq::Testing.fake!
    end
  end
end
