require 'rails_helper'

module Accountify
  RSpec.describe Organisation, type: :module do
    let(:user) { { id: 1 } }
    let(:tenant) { { id: 1 } }

    describe '.create' do
      let(:name) { 'Big Bin Corp' }

      it 'creates an organisation and an event' do
        expect {
          @result = described_class.create(user: user, tenant: tenant, name: name)
        }.to change { Models::Organisation.count }.by(1)
          .and change { Accountify::Organisation::CreatedEvent.count }.by(1)

        expect(@result[:id]).not_to be_nil
        expect(@result[:event_id]).not_to be_nil
        expect(Models::Organisation.last.name).to eq(name)
      end
    end

    describe '.update' do
      let(:updated_name) { 'Big Bin Corp updated' }
      before do
        @organisation = described_class.create(user: user, tenant: tenant, name: 'Big Bin Corp')
      end

      it 'updates the organisation name and creates an event' do
        expect {
          @result = described_class.update(user: user, tenant: tenant, id: @organisation[:id], name: updated_name)
        }.to change { Accountify::Organisation::UpdatedEvent.count }.by(1)

        expect(@result[:id]).to eq(@organisation[:id])
        expect(Models::Organisation.find(@organisation[:id]).name).to eq(updated_name)
      end
    end

    describe '.delete' do
      before do
        @organisation = described_class.create(user: user, tenant: tenant, name: 'Big Bin Corp')
      end

      it 'marks the organisation as deleted and creates a delete event' do
        expect {
          @result = described_class.delete(user: user, tenant: tenant, id: @organisation[:id])
        }.to change { Accountify::Organisation::DeletedEvent.count }.by(1)

        expect(@result[:id]).to eq(@organisation[:id])
        expect(Models::Organisation.find(@organisation[:id]).deleted_at).not_to be_nil
      end
    end
  end
end
