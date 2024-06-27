require 'rails_helper'

module Event
  RSpec.describe CreatedJob, type: :job do
    let(:iam_tenant_id) { 555 }

    before do
      Event::CreatedJob.new.perform({
        'iam_tenant_id' => iam_tenant_id,
        'type' => 'Accountify::Invoice::VoidedEvent' })
    end

    describe 'when Accountify::Invoice::VoidedEvent' do
      it 'performs Accountify::AgedReceivablesReport::GenerateJob async' do
        expect(Accountify::AgedReceivablesReport::GenerateJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_tenant_id' => iam_tenant_id )])])
      end
    end
  end
end
