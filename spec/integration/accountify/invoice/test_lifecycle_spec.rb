require 'rails_helper'

RSpec.describe 'Invoice Lifecycle', type: :integration do
  xit 'transitions as expected' do
    Sidekiq::Testing.disable!

    begin
      load Rails.root.join('script/accountify/invoice/test_lifecycle.rb')

      expect(Accountify::Organisation.count).to eq(1)
      expect(Accountify::Contact.count).to eq(1)
      expect(Accountify::Invoice.count).to eq(1)
    ensure
      Sidekiq::Testing.fake!
    end
  end
end
