require 'rails_helper'

module Accountify
  RSpec.describe Contact do
    let(:iam_user_id) { 12 }
    let(:iam_tenant_id) { 4 }

    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant_id) }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    describe '.delete' do
      let(:id) do
        create(:accountify_contact, iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          first_name: first_name,
          last_name: last_name,
          email: email
        ).id
      end

      it "updates model deleted at" do
        Contact.delete(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)

        contact = Models::Contact.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)

        expect(contact.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        event_id = Contact.delete(
          iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)

        event = Contact::DeletedEvent
          .where(iam_tenant_id: iam_tenant_id)
          .find_by!(id: event_id)

        expect(event.body).to include(
          'contact' => a_hash_including(
            'id' => id,
            'deleted_at' => be_present ))
      end

      it 'associates event with model' do
        event_id = Contact.delete(
          iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)

        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant_id)
          .find_by!(id: id)

        expect(contact.events.last.id).to eq event_id
      end

      it 'queues event created job' do
        event_id = Contact.delete(
          iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user_id,
                'iam_tenant_id' => iam_tenant_id,
                'id' => event_id,
                'type' => 'Accountify::Contact::DeletedEvent')])])
      end
    end
  end
end
