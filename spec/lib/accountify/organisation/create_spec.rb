require 'rails_helper'

module Accountify
  RSpec.describe Organisation do
    let(:iam_user_id) { 12 }
    let(:iam_tenant_id) { 4 }

    let(:name) { 'Big Bin Corp' }

    let(:result) do
      Organisation.create(
        iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, name: name)
    end

    let(:id) { result[0] }

    let(:event_id) { result[1] }

    let(:organisation) do
      Models::Organisation.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)
    end

    let(:event) do
      Organisation::CreatedEvent
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: event_id)
    end

    describe '.create' do
      it 'creates model' do
        expect(organisation.name).to eq(name)
      end

      it 'creates created event' do
        expect(event.body).to eq ({
          'organisation' => {
            'id' => id,
            'name' => name } })
      end

      it 'associates event with model' do
        expect(organisation.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        expect(EventCreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user_id,
                'iam_tenant_id' => iam_tenant_id,
                'id' => event_id,
                'type' => 'Accountify::Organisation::CreatedEvent')])])
      end
    end
  end
end
