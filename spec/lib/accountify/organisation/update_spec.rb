require 'rails_helper'

module Accountify
  RSpec.describe Organisation do
    let(:user_id) { 12 }

    let(:tenant_id) { 4 }

    let(:id) do
      create(:accountify_organisation, tenant_id: tenant_id).id
    end

    let!(:organisation) do
      Organisation.update(
        user_id: user_id, tenant_id: tenant_id,
        id: id, name: 'Big Bin Corp updated')
    end

    let(:organisation_model) do
      Models::Organisation.where(tenant_id: tenant_id).find_by!(id: id)
    end

    let(:event_model) do
      Organisation::UpdatedEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: organisation[:events].last[:id])
    end

    describe '.update' do
      it 'updates model' do
        expect(organisation_model.name).to eq('Big Bin Corp updated')
      end

      it 'creates updated event' do
        expect(event_model.body).to eq({
          'organisation' => {
            'id' => organisation[:id],
            'name' => 'Big Bin Corp updated' } })
      end

      it 'associates event with model' do
        expect(event_model.id).to eq organisation[:events].last[:id]
      end

      it 'queues event created job' do
        expect(EventCreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'user_id' => user_id,
                'tenant_id' => tenant_id,
                'id' => organisation[:events].last[:id],
                'type' => 'Accountify::Organisation::UpdatedEvent')])])
      end
    end
  end
end
