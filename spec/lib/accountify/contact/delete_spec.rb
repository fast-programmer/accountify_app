require 'rails_helper'

module Accountify
  RSpec.describe Contact do
    let(:user_id) { 12 }

    let(:tenant_id) { 4 }

    let(:organisation) do
      create(:accountify_organisation, tenant_id: tenant_id)
    end

    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    let(:id) do
      create(:accountify_contact, tenant_id: tenant_id,
        organisation_id: organisation.id,
        first_name: first_name,
        last_name: last_name,
        email: email
      ).id
    end

    let!(:contact) do
      Contact.delete(user_id: user_id, tenant_id: tenant_id, id: id)
    end

    let(:contact_model) do
      Models::Contact.where(tenant_id: tenant_id).find_by!(id: id)
    end

    let(:event_model) do
      Models::Contact::DeletedEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: contact[:events].last[:id])
    end

    describe '.delete' do
      it "updates model deleted at" do
        expect(contact_model.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        expect(event_model.body).to include(
          'contact' => a_hash_including(
            'id' => contact[:id],
            'deleted_at' => be_present ))
      end

      it 'associates event with model' do
        expect(contact_model.events.last.id).to eq contact[:events].last[:id]
      end
    end
  end
end
