require 'rails_helper'

module Accountify
  RSpec.describe Organisation do
    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:id) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id).id
    end

    let!(:event_id) do
      Organisation.update(
        iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id,
        id: id, name: 'Big Bin Corp updated')
    end

    let(:organisation) do
      Models::Organisation
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: id)
    end

    let(:event) do
      Organisation::UpdatedEvent
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: event_id)
    end

    describe '.update' do
      it 'updates model' do
        expect(organisation.name).to eq('Big Bin Corp updated')
      end

      it 'creates updated event' do
        expect(event.body).to eq({
          'organisation' => {
            'id' => id,
            'name' => 'Big Bin Corp updated' } })
      end

      it 'associates event with model' do
        event_id = Organisation.update(
          iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id, name: 'Big Bin Corp updated')

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
                'type' => 'Accountify::Organisation::UpdatedEvent')])])
      end
    end
  end
end
