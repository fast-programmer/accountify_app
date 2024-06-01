
require 'rails_helper'

module Accountify
  RSpec.describe Organisation do
    let(:iam_user_id) { 12 }
    let(:iam_tenant_id) { 4 }

    let(:name) { 'Big Bin Corp' }

    let(:id) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id).id
    end

    let!(:event_id) do
      Organisation.delete(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)
    end

    let(:organisation) do
      Models::Organisation.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)
    end

    let(:event) do
      Organisation::DeletedEvent
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: event_id)
    end

    describe '.delete' do
      it "updates model deleted at" do
        expect(organisation.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        expect(event.body).to include(
          'organisation' => a_hash_including(
            'id' => id,
            'deleted_at' => be_present ))
      end

      it 'associates event with model' do
        expect(organisation.events.last.id).to eq event_id
      end

      it 'queues event created job' do
        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user_id,
                'iam_tenant_id' => iam_tenant_id,
                'id' => event_id,
                'type' => 'Accountify::Organisation::DeletedEvent')])])
      end
    end
  end
end
