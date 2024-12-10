require 'rails_helper'

module Accountify
  RSpec.describe Contact do
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
        email: email).id
    end

    let!(:contact) do
      Contact.update(
        user_id: user_id,
        tenant_id: tenant_id,
        id: id,
        first_name: 'Johnny',
        last_name: 'Doherty',
        email: 'johnny.doherty@coolbincompany.org')
    end

    let(:contact_model) do
      Models::Contact.where(tenant_id: tenant_id).find_by!(id: contact[:id])
    end

    let(:event_model) do
      Contact::UpdatedEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: contact[:events].last[:id])
    end

    describe '.update' do
      it 'updates model' do
        expect(contact_model.first_name).to eq('Johnny')
        expect(contact_model.last_name).to eq('Doherty')
        expect(contact_model.email).to eq('johnny.doherty@coolbincompany.org')
      end

      it 'creates updated event' do
        expect(event_model.body).to eq({
          'contact' => {
            'id' => contact[:id],
            'first_name' => "Johnny",
            'last_name' => "Doherty",
            'email' => 'johnny.doherty@coolbincompany.org' } })
      end

      it 'associates event with model' do
        expect(event_model.id).to eq(contact[:events].last[:id])
      end
    end
  end
end
