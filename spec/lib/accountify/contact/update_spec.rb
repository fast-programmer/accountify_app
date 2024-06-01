require 'rails_helper'

module Accountify
  RSpec.describe Contact do
    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant_id) }

    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:email) { 'john.doe@example.com' }

    let(:id) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation.id,
        first_name: first_name,
        last_name: last_name,
        email: email).id
    end

    let!(:event_id) do
      Contact.update(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: id,
        first_name: 'Johnny',
        last_name: 'Doherty',
        email: 'johnny.doherty@coolbincompany.org')
    end

    let(:contact) do
      Models::Contact.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)
    end

    let(:event) do
      Contact::UpdatedEvent
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: event_id)
    end

    describe '.update' do
      it 'updates model' do
        expect(contact.first_name).to eq('Johnny')
        expect(contact.last_name).to eq('Doherty')
        expect(contact.email).to eq('johnny.doherty@coolbincompany.org')
      end

      it 'creates updated event' do
        expect(event.body).to eq({
          'contact' => {
            'id' => id,
            'first_name' => "Johnny",
            'last_name' => "Doherty",
            'email' => 'johnny.doherty@coolbincompany.org' } })
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
                'type' => 'Accountify::Contact::UpdatedEvent')])])
      end
    end
  end
end
