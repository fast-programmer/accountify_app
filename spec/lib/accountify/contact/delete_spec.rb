require 'rails_helper'

module Accountify
  RSpec.describe Contact do
    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:organisation) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
    end

    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    let(:id) do
      create(:accountify_contact, iam_tenant_id: iam_tenant_id,
        organisation_id: organisation.id,
        first_name: first_name,
        last_name: last_name,
        email: email
      ).id
    end

    let!(:event_id) do
      Contact.delete(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)
    end

    let(:contact) do
      Models::Contact.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)
    end

    let(:event) do
      Contact::DeletedEvent
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: event_id)
    end

    describe '.delete' do
      it "updates model deleted at" do
        expect(contact.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        expect(event.body).to include(
          'contact' => a_hash_including(
            'id' => id,
            'deleted_at' => be_present ))
      end

      it 'associates event with model' do
        expect(contact.events.last.id).to eq event_id
      end

      it 'queues event created job' do
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
