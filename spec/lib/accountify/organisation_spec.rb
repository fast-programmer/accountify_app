require 'rails_helper'

module Accountify
  RSpec.describe Organisation do
    let(:iam_user) { { id: 12 } }
    let(:iam_tenant) { { id: 4 } }

    let(:name) { 'Big Bin Corp' }

    describe '.create' do
      it 'creates model' do
        organisation_id, _event_id = Organisation.create(
          iam_user: iam_user, iam_tenant: iam_tenant, name: name)

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: organisation_id)

        expect(organisation.name).to eq(name)
      end

      it 'creates created event' do
        organisation_id, event_id = Organisation.create(
          iam_user: iam_user, iam_tenant: iam_tenant, name: name)

        event = Organisation::CreatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to eq ({
          'organisation' => {
            'id' => organisation_id,
            'name' => name } })
      end

      it 'associates event with model' do
        id, event_id = Organisation.create(iam_user: iam_user, iam_tenant: iam_tenant, name: name)

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(organisation.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        _id, event_id = Organisation.create(iam_user: iam_user, iam_tenant: iam_tenant, name: name)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Organisation::CreatedEvent')])])
      end
    end

    describe '.find_by_id' do
      let(:id) { create(:accountify_organisation, iam_tenant_id: iam_tenant[:id], name: name).id }

      it 'returns attributes' do
        organisation = Organisation.find_by_id(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(organisation).to eq({ id: id, name: name })
      end
    end

    describe '.update' do
      let(:id) { create(:accountify_organisation, iam_tenant_id: iam_tenant[:id]).id }
      let(:updated_name) { 'Big Bin Corp updated' }

      it 'updates model' do
        Organisation.update(iam_user: iam_user, iam_tenant: iam_tenant, id: id, name: updated_name)

        organisation = Models::Organisation.where(iam_tenant_id: iam_tenant[:id]).find_by!(id: id)

        expect(organisation.name).to eq(updated_name)
      end

      it 'creates updated event' do
        event_id = Organisation.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id, name: updated_name)

        event = Organisation::UpdatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to eq({
          'organisation' => {
            'id' => id,
            'name' => updated_name } })
      end

      it 'associates event with model' do
        event_id = Organisation.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id, name: updated_name)

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(organisation.events.last.id).to eq event_id
      end

      it 'queues event created job' do
        event_id = Organisation.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id, name: name)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Organisation::UpdatedEvent')])])
      end
    end

    describe '.delete' do
      let(:id) { create(:accountify_organisation, iam_tenant_id: iam_tenant[:id]).id }

      it "updates model deleted at" do
        Organisation.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(organisation.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        event_id = Organisation.delete(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        event = Organisation::DeletedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to include(
          'organisation' => a_hash_including(
            'id' => id,
            'deleted_at' => be_present ))
      end

      it 'associates event with model' do
        event_id = Organisation.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(organisation.events.last.id).to eq event_id
      end

      it 'queues event created job' do
        event_id = Organisation.delete(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Organisation::DeletedEvent')])])
      end
    end
  end
end
