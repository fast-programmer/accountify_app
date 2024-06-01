require 'rails_helper'

module Accountify
  RSpec.describe Contact do
    let(:iam_user_id) { 12 }
    let(:iam_tenant_id) { 4 }

    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant_id) }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    describe '.create' do
      it 'creates model' do
        id, _event_id = Contact.create(
          iam_user_id: iam_user_id,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          first_name: first_name,
          last_name: last_name,
          email: email)

        contact = Models::Contact.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)

        expect(contact.first_name).to eq(first_name)
        expect(contact.last_name).to eq(last_name)
        expect(contact.email).to eq(email)
      end

      it 'creates created event' do
        id, event_id = Contact.create(
          iam_user_id: iam_user_id,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          first_name: first_name,
          last_name: last_name,
          email: email)

        event = Contact::CreatedEvent
          .where(iam_tenant_id: iam_tenant_id)
          .find_by!(id: event_id)

        expect(event.body).to eq({
          'contact' => {
            'id' => id,
            'first_name' => first_name,
            'last_name' => last_name,
            'email' => email } })
      end

      it 'associates event with model' do
        id, event_id = Contact.create(
          iam_user_id: iam_user_id,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          first_name: first_name,
          last_name: last_name,
          email: email)

        contact = Models::Contact.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)

        expect(contact.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        _id, event_id = Contact.create(
          iam_user_id: iam_user_id,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          first_name: first_name,
          last_name: last_name,
          email: email)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user_id,
                'iam_tenant_id' => iam_tenant_id,
                'id' => event_id,
                'type' => 'Accountify::Contact::CreatedEvent')])])
      end
    end
  end
end
