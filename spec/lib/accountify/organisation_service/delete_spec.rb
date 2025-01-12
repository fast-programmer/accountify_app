
require 'rails_helper'

module Accountify
  RSpec.describe Organisation do
    let(:user_id) { 12 }
    let(:tenant_id) { 4 }

    let(:name) { 'Big Bin Corp' }

    let(:id) do
      create(:accountify_organisation, tenant_id: tenant_id).id
    end

    let!(:organisation) do
      OrganisationService.delete(user_id: user_id, tenant_id: tenant_id, id: id)
    end

    let(:organisation_model) do
      Organisation.where(tenant_id: tenant_id).find_by!(id: id)
    end

    let(:event_model) do
      OrganisationDeletedEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: organisation[:events].last[:id])
    end

    describe '.delete' do
      it "updates model deleted at" do
        expect(organisation_model.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        expect(event_model.body).to include(
          'organisation' => a_hash_including(
            'id' => id,
            'deleted_at' => be_present ))
      end

      it 'associates event with model' do
        expect(organisation_model.events.last.id).to eq organisation[:events].last[:id]
      end
    end
  end
end
