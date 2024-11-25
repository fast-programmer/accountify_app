require 'rails_helper'

module Accountify
  RSpec.describe Contact do
    let(:user_id) { 12 }

    let(:tenant_id) { 4 }

    let(:organisation) { create(:accountify_organisation, tenant_id: tenant_id) }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    let!(:contact) do
      Contact.create(
        user_id: user_id,
        tenant_id: tenant_id,
        organisation_id: organisation.id,
        first_name: first_name,
        last_name: last_name,
        email: email)
    end

    let(:contact_model) do
      Models::Contact.where(tenant_id: tenant_id).find_by!(id: contact[:id])
    end

    let(:event_model) do
      Contact::CreatedEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: contact[:events].last[:id])
    end

    describe '.create' do
      it 'creates model' do
        expect(contact_model.first_name).to eq(first_name)
        expect(contact_model.last_name).to eq(last_name)
        expect(contact_model.email).to eq(email)
      end

      it 'creates created event' do
        expect(event_model.body).to eq({
          'contact' => {
            'id' => contact[:id],
            'first_name' => first_name,
            'last_name' => last_name,
            'email' => email } })
      end

      it 'associates event with model' do
        expect(contact_model.events.last.id).to eq(contact[:events].last[:id])
      end

      it 'queues event created job' do
        expect(EventCreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'user_id' => user_id,
                'tenant_id' => tenant_id,
                'id' => contact[:events].last[:id],
                'type' => 'Accountify::Contact::CreatedEvent')])])
      end
    end
  end
end
