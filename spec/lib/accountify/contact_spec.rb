require 'rails_helper'

module Accountify
  RSpec.describe Contact do
    let(:iam_user) { { id: 12 } }
    let(:iam_tenant) { { id: 4 } }

    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant[:id]) }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    describe '.create' do
      it 'creates model' do
        id, _event_id = Contact.create(
          iam_user: iam_user, iam_tenant: iam_tenant, organisation_id: organisation.id,
          first_name: first_name, last_name: last_name, email: email)

        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(contact.first_name).to eq(first_name)
        expect(contact.last_name).to eq(last_name)
        expect(contact.email).to eq(email)
      end

      it 'creates created event' do
        id, event_id = Contact.create(
          iam_user: iam_user, iam_tenant: iam_tenant, organisation_id: organisation.id,
          first_name: first_name, last_name: last_name, email: email)

        event = Contact::CreatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
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
          iam_user: iam_user, iam_tenant: iam_tenant, organisation_id: organisation.id,
          first_name: first_name, last_name: last_name, email: email)

        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(contact.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        _id, event_id = Contact.create(
          iam_user: iam_user, iam_tenant: iam_tenant, organisation_id: organisation.id,
          first_name: first_name, last_name: last_name, email: email)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Contact::CreatedEvent')])])
      end
    end

    describe '.find_by_id' do
      let(:id) do
        create(:accountify_contact, iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation.id,
          first_name: first_name,
          last_name: last_name,
          email: email
        ).id
      end

      it 'returns attributes' do
        contact = Contact.find_by_id(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(contact).to eq({
          id: id,
          first_name: first_name,
          last_name: last_name,
          email: email })
      end
    end


    describe '.update' do
      let(:id) do
        create(:accountify_contact, iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation.id,
          first_name: first_name,
          last_name: last_name,
          email: email).id
      end

      let(:updated_first_name) { 'Johnny' }
      let(:updated_last_name) { 'Doherty' }
      let(:updated_email) { 'johnny.doherty@coolbincompany.org' }

      it 'updates model' do
        Contact.update(iam_user: iam_user, iam_tenant: iam_tenant, id: id,
          first_name: updated_first_name,
          last_name: updated_last_name,
          email: updated_email)

        contact = Models::Contact.where(iam_tenant_id: iam_tenant[:id]).find_by!(id: id)

        expect(contact.first_name).to eq(updated_first_name)
        expect(contact.last_name).to eq(updated_last_name)
        expect(contact.email).to eq(updated_email)
        expect(contact.email).to eq(updated_email)
      end

      it 'creates updated event' do
        event_id = Contact.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id,
          first_name: updated_first_name, last_name: updated_last_name, email: updated_email)

        event = Contact::UpdatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to eq({
          'contact' => {
            'id' => id,
            'first_name' => updated_first_name,
            'last_name' => updated_last_name,
            'email' => updated_email } })
      end

      it 'associates event with model' do
        event_id = Contact.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id,
          first_name: first_name, last_name: last_name, email: updated_email)

        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(contact.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        event_id = Contact.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id,
          first_name: first_name, last_name: last_name, email: updated_email)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Contact::UpdatedEvent')])])
      end
    end

    describe '.delete' do
      let(:id) do
        create(:accountify_contact, iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation.id,
          first_name: first_name,
          last_name: last_name,
          email: email
        ).id
      end

      it "updates model deleted at" do
        Contact.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(contact.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        event_id = Contact.delete(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        event = Contact::DeletedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to include(
          'contact' => a_hash_including(
            'id' => id,
            'deleted_at' => be_present ))
      end

      it 'associates event with model' do
        event_id = Contact.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(contact.events.last.id).to eq event_id
      end

      it 'queues event created job' do
        event_id = Contact.delete(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Contact::DeletedEvent')])])
      end
    end
  end
end
