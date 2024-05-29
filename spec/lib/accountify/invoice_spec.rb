require 'rails_helper'

module Accountify
  RSpec.describe Invoice do
    let(:iam_user) { { id: 12 } }
    let(:iam_tenant) { { id: 4 } }

    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant[:id]) }

    let(:contact) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant[:id], organisation_id: organisation.id)
    end

    let(:currency_code) { 'AUD' }

    let(:due_date) { Date.today + 30.days }

    let(:sub_total_amount) { BigDecimal('1000.00') }
    let(:sub_total_currency_code) { 'AUD' }
    let(:sub_total) do
      {
        amount: sub_total_amount,
        currency_code: sub_total_currency_code
      }
    end

    describe '.create' do
      it 'creates model' do
        id, _event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          sub_total: sub_total)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.status).to eq(Invoice::Status::DRAFT)
        expect(invoice.currency_code).to eq(currency_code)
        expect(invoice.due_date).to eq(due_date)
        expect(invoice.sub_total_amount).to eq(sub_total_amount)
      end

      it 'creates created event' do
        id, event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          sub_total: sub_total)

        event = Invoice::CreatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to eq({
          'invoice' => {
            'id' => id,
            'status' => Invoice::Status::DRAFT,
            'currency_code' => currency_code,
            'due_date' => due_date.to_s,
            'sub_total' => {
              'amount' => sub_total[:amount].to_s,
              'currency_code' => sub_total[:currency_code] } } })
      end

      it 'associates event with model' do
        id, event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          sub_total: sub_total)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        _id, event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          sub_total: sub_total)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Invoice::CreatedEvent')])])
      end
    end

    describe '.find_by_id' do
      let(:id) do
        create(:accountify_invoice, :draft,
          iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: sub_total_amount
        ).id
      end

      it 'returns attributes' do
        invoice = Invoice.find_by_id(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(invoice).to have_attributes({
          id: id,
          status: Invoice::Status::DRAFT,
          currency_code: currency_code,
          due_date: due_date,
          sub_total: {
            amount: sub_total[:amount],
            currency_code: sub_total[:currency_code ]} })
      end
    end

    describe '.update' do
      let(:id) do
        create(:accountify_invoice, iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation.id,
          contact_id: contact.id,
          status: status,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: sub_total_amount).id
      end

      let(:updated_status) { 'completed' }
      let(:updated_due_date) { due_date + 15.days }
      let(:updated_sub_total_amount) { 1200.00 }

      it 'updates model' do
        Invoice.update(iam_user: iam_user, iam_tenant: iam_tenant, id: id,
          status: updated_status, due_date: updated_due_date,
          sub_total_amount: updated_sub_total_amount)

        invoice = Models::Invoice.where(iam_tenant_id: iam_tenant[:id]).find_by!(id: id)

        expect(invoice.status).to eq(updated_status)
        expect(invoice.due_date).to eq(updated_due_date)
        expect(invoice.sub_total_amount).to eq(updated_sub_total_amount)
      end

      it 'creates updated event' do
        event_id = Invoice.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id,
          status: updated_status, due_date: updated_due_date,
          sub_total_amount: updated_sub_total_amount)

        event = Invoice::UpdatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to eq({
          'invoice' => {
            'id' => id,
            'status' => updated_status,
            'due_date' => updated_due_date.to_s,
            'sub_total_amount' => updated_sub_total_amount.to_s } })
      end

      it 'associates event with model' do
        event_id = Invoice.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id,
          status: updated_status, due_date: updated_due_date,
          sub_total_amount: updated_sub_total_amount)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        event_id = Invoice.update(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id,
          status: updated_status, due_date: updated_due_date,
          sub_total_amount: updated_sub_total_amount)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Invoice::UpdatedEvent')])])
      end
    end

    describe '.delete' do
      let(:id) do
        create(:accountify_invoice, iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation.id,
          contact_id: contact.id,
          status: status,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: sub_total_amount).id
      end

      it "updates model deleted at" do
        Invoice.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        event_id = Invoice.delete(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        event = Invoice::DeletedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to include(
          'invoice' => a_hash_including(
            'id' => id,
            'deleted_at' => be_present))
      end

      it 'associates event with model' do
        event_id = Invoice.delete(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        event_id = Invoice.delete(
          iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Invoice::DeletedEvent')])])
      end
    end
  end
end
