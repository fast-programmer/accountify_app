require 'rails_helper'

module Event
  RSpec.describe CreatedJob, type: :job do
    let(:iam_tenant_id) { 555 }

    before do
      Event::CreatedJob.new.perform({
        'iam_tenant_id' => iam_tenant_id,
        'type' => 'Accountify::Invoice::DeletedEvent' })
    end

    describe 'when Accountify::Invoice::DeletedEvent' do
      it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
        expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_tenant_id' => iam_tenant_id )])])
      end
    end
  end
end
