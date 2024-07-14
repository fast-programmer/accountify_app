require 'rails_helper'

RSpec.describe EventCreatedJob, type: :job do
  let(:iam_tenant_id) { 555 }

  before do
    EventCreatedJob.new.perform({
      'iam_tenant_id' => iam_tenant_id,
      'type' => 'Accountify::Invoice::UpdatedEvent' })
  end

  describe 'when Accountify::Invoice::UpdatedEvent' do
    it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'iam_tenant_id' => iam_tenant_id )])])
    end
  end
end
