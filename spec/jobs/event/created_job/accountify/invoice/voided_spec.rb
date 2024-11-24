require 'rails_helper'

RSpec.describe EventCreatedJob, type: :job do
  let(:tenant_id) { 555 }

  before do
    EventCreatedJob.new.perform({
      'tenant_id' => tenant_id,
      'type' => 'Accountify::Invoice::VoidedEvent' })
  end

  describe 'when Accountify::Invoice::VoidedEvent' do
    it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'tenant_id' => tenant_id )])])
    end
  end
end
