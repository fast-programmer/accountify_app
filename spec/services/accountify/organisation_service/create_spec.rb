require 'rails_helper'

module Accountify
  RSpec.describe OrganisationService do
    let(:user_id) { 12 }
    let(:tenant_id) { 4 }

    let(:name) { 'Big Bin Corp' }

    let(:organisation) do
      OrganisationService.create(
        user_id: user_id, tenant_id: tenant_id, name: name)
    end

    let(:organisation_model) do
      Organisation.where(tenant_id: tenant_id).find_by!(id: organisation[:id])
    end

    let(:event_model) do
      OrganisationCreatedEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: organisation[:events].last[:id])
    end

    describe '.create' do
      it 'creates model' do
        expect(organisation_model.name).to eq(name)
      end

      it 'creates created event' do
        expect(event_model.body).to eq ({
          'organisation' => {
            'id' => organisation[:id],
            'name' => name } })
      end

      it 'associates event with model' do
        expect(organisation_model.events.last.id).to eq(organisation[:events].last[:id])
      end
    end
  end
end
