require 'rails_helper'

module Accountify
  RSpec.describe Contact do
    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant_id) }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    let!(:result) do
      Contact.create(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation.id,
        first_name: first_name,
        last_name: last_name,
        email: email)
    end

    let(:id) { result[0] }

    let(:event_id) { result[1] }

    let(:contact) do
      Models::Contact.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)
    end

    let(:event) do
      Contact::CreatedEvent
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: event_id)
    end

    describe '.create' do
      it 'creates model' do
        expect(contact.first_name).to eq(first_name)
        expect(contact.last_name).to eq(last_name)
        expect(contact.email).to eq(email)
      end

      it 'creates created event' do
        expect(event.body).to eq({
          'contact' => {
            'id' => id,
            'first_name' => first_name,
            'last_name' => last_name,
            'email' => email } })
      end

      it 'associates event with model' do
        expect(contact.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
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
