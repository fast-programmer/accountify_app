require 'rails_helper'

module Accountify
  RSpec.describe ContactService do
    let(:user_id) { 12 }

    let(:tenant_id) { 4 }

    let(:organisation) { create(:accountify_organisation, tenant_id: tenant_id) }

    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    let(:id) do
      create(:accountify_contact,
        tenant_id: tenant_id,
        organisation_id: organisation.id,
        first_name: first_name,
        last_name: last_name,
        email: email
      ).id
    end

    let(:contact) do
      ContactService.find_by_id(user_id: user_id, tenant_id: tenant_id, id: id)
    end

    describe '.find_by_id' do
      it 'returns attributes' do
        expect(contact).to eq({
          id: id,
          first_name: first_name,
          last_name: last_name,
          email: email,
          events: []})
      end
    end
  end
end
