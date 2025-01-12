require 'rails_helper'

module Accountify
  RSpec.describe OrganisationService do
    let(:user_id) { 12 }

    let(:tenant_id) { 4 }

    let(:name) { 'Big Bin Corp' }

    let(:id) do
      create(:accountify_organisation, tenant_id: tenant_id, name: name).id
    end

    let(:organisation) do
      OrganisationService.find_by_id(user_id: user_id, tenant_id: tenant_id, id: id)
    end

    describe '.find_by_id' do
      it 'returns attributes' do
        expect(organisation).to eq({ id: id, name: name, events: [] })
      end
    end
  end
end
