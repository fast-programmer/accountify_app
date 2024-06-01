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

    let(:line_item_1) do
      create(:accountify_invoice_line_item,
        invoice_id: id,
        description: "Leather Boots",
        unit_amount_amount: BigDecimal("300.0"),
        unit_amount_currency_code: "AUD",
        quantity: 2)
    end

    let(:line_item_2) do
      create(:accountify_invoice_line_item,
        invoice_id: id,
        description: "White Pants",
        unit_amount_amount: BigDecimal("400.0"),
        unit_amount_currency_code: "AUD",
        quantity: 3)
    end

    let!(:line_items) { [line_item_1, line_item_2] }

    let!(:event_id) do
      Invoice.update(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: id,
        contact_id: contact_2.id,
        organisation_id: organisation_2.id,
        due_date: current_date + 14.days,
        line_items: [{
          description: "Green Jumper",
          unit_amount: {
            amount: BigDecimal("25.00"),
            currency_code: "AUD" },
          quantity: 3
        }, {
          description: "Blue Socks",
          unit_amount: {
            amount: BigDecimal("5.00"),
            currency_code: "AUD" },
          quantity: 4 }])
    end

    let(:invoice) do
      Models::Invoice.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)
    end

    let(:event) do
      Invoice::UpdatedEvent
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: event_id)
    end

    describe '.update' do
      it 'updates model' do
        expect(invoice).to have_attributes(
          organisation_id: organisation_2.id,
          contact_id: contact_2.id,
          status: Invoice::Status::DRAFT,
          currency_code: "AUD",
          due_date: current_date + 14.days,
          line_items: match_array([
            have_attributes(
              description: "Green Jumper",
              unit_amount_amount: BigDecimal("25.00"),
              unit_amount_currency_code: "AUD",
              quantity: 3 ),
            have_attributes(
              description: "Blue Socks",
              unit_amount_amount: BigDecimal("5.00"),
              unit_amount_currency_code: "AUD",
              quantity: 4 ) ]),
          sub_total_amount: BigDecimal("95.00"),
          sub_total_currency_code: "AUD")
      end

      it 'creates updated event' do
        expect(event.body).to eq({
          'invoice' => {
            'id' => id,
            'contact_id' => contact_2.id,
            'organisation_id' => organisation_2.id,
            'status' => Invoice::Status::DRAFT,
            'currency_code' => "AUD",
            'due_date' => (current_date + 14.days).to_s,
            'line_items' => [{
              'description' => "Green Jumper",
              'unit_amount_amount' => BigDecimal("25.00").to_s,
              'unit_amount_currency_code' => "AUD",
              'quantity' => 3
            }, {
              'description' => "Blue Socks",
              'unit_amount_amount' => BigDecimal("5.00").to_s,
              'unit_amount_currency_code' => "AUD",
              'quantity' => 4 }],
            'sub_total' => {
              'amount' => BigDecimal("95.00").to_s,
              'currency_code' => "AUD" } } })
      end

      it 'associates event with model' do
        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
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
