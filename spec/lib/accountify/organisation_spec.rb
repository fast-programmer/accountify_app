require 'rails_helper'

module Accountify
  RSpec.describe Organisation do
    let(:iam_user) { { id: 12, email: 'peter.stevens@coolbincompany.co' } }
    let(:iam_tenant) { { id: 4, name: 'Cool Bin Company', domain: 'cool-bin-company' } }

    let(:name) { 'Big Bin Corp' }

    describe '.create' do
      it 'creates model' do
        organisation, _ = Organisation
          .create(iam_user: iam_user, iam_tenant: iam_tenant, name: name)

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: organisation[:id])

        expect(organisation[:name]).to eq(name)
      end

      it 'creates created event' do
        organisation, event = Organisation
          .create(iam_user: iam_user, iam_tenant: iam_tenant, name: name)

        event = Organisation::CreatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event[:id])

        expect(event.body).to eq ({
          'organisation' => {
            'id' => organisation[:id],
            'name' => name } })

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: organisation[:id])

        expect(organisation.events.last).to eq(event)
      end

      it 'queues event created job' do
        _, event = Organisation.create(iam_user: iam_user, iam_tenant: iam_tenant, name: name)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event[:id],
                'type' => event[:type])])])
      end
    end

    describe '.update' do
      let(:id) { create(:accountify_organisation).id }
      let(:updated_name) { 'Big Bin Corp updated' }

      it 'updates model' do
        Organisation
          .update(
            iam_user: iam_user, iam_tenant: iam_tenant,
            id: id, name: updated_name)

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(organisation.name).to eq(updated_name)
      end

      it 'creates updated event' do
        organisation, event = Organisation
          .update(
            iam_user: iam_user, iam_tenant: iam_tenant,
            id: id, name: updated_name)

        event = Organisation::UpdatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event[:id])

        expect(event.body).to eq({
          'organisation' => {
            'id' => organisation[:id],
            'name' => updated_name } })

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: organisation[:id])

        expect(organisation.events.last).to eq(event)
      end

      it 'queues event created job' do
        _, event = Organisation.update(
          iam_user: iam_user, iam_tenant: iam_tenant,
          id: id, name: name)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event[:id],
                'type' => event[:type])])])
      end
    end

    describe '.delete' do
      let(:id) { create(:accountify_organisation).id }

      it 'updates organisation deleted at' do
        Organisation
          .delete(
            iam_user: iam_user, iam_tenant: iam_tenant,
            id: id)

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(organisation.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        organisation, event = Organisation
          .delete(
            iam_user: iam_user, iam_tenant: iam_tenant,
            id: id)

        event = Organisation::DeletedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event[:id])

        expect(event.body).to include(
          'organisation' => a_hash_including(
            'id' => organisation[:id],
            'deleted_at' => be_present ))

        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: organisation[:id])

        expect(organisation.events.last).to eq(event)
      end

      it 'queues event created job' do
        _, event = Organisation
          .delete(
            iam_user: iam_user, iam_tenant: iam_tenant,
            id: id)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event[:id],
                'type' => event[:type])])])
      end
    end
  end
end
