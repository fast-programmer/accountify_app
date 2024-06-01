require 'rails_helper'

module Accountify
  RSpec.describe Invoice do
    let(:current_date) { Date.today }

    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:organisation_1) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
    end

    let(:organisation_2) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
    end

    let(:contact_1) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant_id, organisation_id: organisation_1.id)
    end

    let(:contact_2) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant_id, organisation_id: organisation_2.id)
    end

    let(:id) do
      create(:accountify_invoice,
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation_1.id,
        contact_id: contact_1.id,
        currency_code: "AUD",
        status: Invoice::Status::DRAFT,
        due_date: current_date + 30.days,
        sub_total_amount: BigDecimal("600.00"),
        sub_total_currency_code: "AUD"
      ).id
    end

    let(:line_item) do
      create(:accountify_invoice_line_item,
        invoice_id: id,
        description: "Leather Boots",
        unit_amount_amount: BigDecimal("300.0"),
        unit_amount_currency_code: "AUD",
        quantity: 2)
    end

    describe '.update' do
      it 'updates model' do
        Invoice.update(
          iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id,
          id: id,
          contact_id: contact_2.id,
          organisation_id: organisation_2.id,
          due_date: current_date + 14.days,
          line_items: [{
            description: "White Shirt",
            unit_amount: {
              amount: BigDecimal("25.00"),
              currency_code: "AUD" },
            quantity: 3 }])

        invoice = Models::Invoice.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)

        expect(invoice.organisation_id).to eq(organisation_2.id)
        expect(invoice.contact_id).to eq(contact_2.id)
        expect(invoice.status).to eq(Invoice::Status::DRAFT)
        expect(invoice.currency_code).to eq("AUD")
        expect(invoice.due_date).to eq(current_date + 14.days)

        expect(invoice.line_items).to match_array([
          have_attributes(
            description: "White Shirt",
            unit_amount_amount: BigDecimal("25.00"),
            unit_amount_currency_code: "AUD",
            quantity: 3) ])

        expect(invoice.sub_total_amount).to eq(BigDecimal("75.00"))
        expect(invoice.sub_total_currency_code).to eq("AUD")
      end

      it 'creates updated event' do
        event_id = Invoice.update(
          iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id,
          id: id,
          contact_id: contact_2.id,
          organisation_id: organisation_2.id,
          due_date: current_date + 14.days,
          line_items: [{
            description: "White Shirt",
            unit_amount: {
              amount: BigDecimal("25.00"),
              currency_code: "AUD" },
            quantity: 3 }])

        event = Invoice::UpdatedEvent
          .where(iam_tenant_id: iam_tenant_id)
          .find_by!(id: event_id)

        expect(event.body).to eq({
          'invoice' => {
            'id' => id,
            'contact_id' => contact_2.id,
            'organisation_id' => organisation_2.id,
            'status' => Invoice::Status::DRAFT,
            'currency_code' => "AUD",
            'due_date' => (current_date + 14.days).to_s,
            'line_items' => [{
              'description' => "White Shirt",
              'unit_amount_amount' => BigDecimal("25.00").to_s,
              'unit_amount_currency_code' => "AUD",
              'quantity' => 3 }],
            'sub_total' => {
              'amount' => BigDecimal("75.00").to_s,
              'currency_code' => "AUD" } } })
      end

      it 'associates event with model' do
        event_id = Invoice.update(
          iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id,
          id: id,
          contact_id: contact_2.id,
          organisation_id: organisation_2.id,
          due_date: current_date + 14.days,
          line_items: [{
            description: "White Shirt",
            unit_amount: {
              amount: BigDecimal("25.00"),
              currency_code: "AUD" },
            quantity: 3 }])

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant_id)
          .find_by!(id: id)

        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        event_id = Invoice.update(
          iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id,
          id: id,
          contact_id: contact_2.id,
          organisation_id: organisation_2.id,
          due_date: current_date + 14.days,
          line_items: [{
            description: "White Shirt",
            unit_amount: {
              amount: BigDecimal("25.00"),
              currency_code: "AUD" },
            quantity: 3 }])

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user_id,
                'iam_tenant_id' => iam_tenant_id,
                'id' => event_id,
                'type' => 'Accountify::Invoice::UpdatedEvent')])])
      end
    end
  end
end
