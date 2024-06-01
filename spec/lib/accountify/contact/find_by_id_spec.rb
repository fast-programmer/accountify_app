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
        email: email
      ).id
    end

    let(:contact) do
      Contact.find_by_id(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)
    end

    describe '.find_by_id' do
      it 'returns attributes' do
        expect(contact).to eq({
          id: id,
          first_name: first_name,
          last_name: last_name,
          email: email })
      end
    end
  end
end
