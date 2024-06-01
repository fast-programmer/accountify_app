require 'rails_helper'

module Accountify
  RSpec.describe Organisation do
    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:name) { 'Big Bin Corp' }

    let(:id) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id, name: name).id
    end

    let(:organisation) do
      Organisation.find_by_id(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)
    end

    describe '.find_by_id' do
      it 'returns attributes' do
        expect(organisation).to eq({ id: id, name: name })
      end
    end
  end
end
