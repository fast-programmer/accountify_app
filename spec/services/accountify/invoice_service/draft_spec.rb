require 'rails_helper'

module Accountify
  RSpec.describe InvoiceService do
    let(:current_date) { Date.today }

    let(:user_id) { 12 }

    let(:tenant_id) { 4 }

    let(:organisation) do
      create(:accountify_organisation, tenant_id: tenant_id)
    end

    let(:contact) do
      create(:accountify_contact,
        tenant_id: tenant_id, organisation_id: organisation.id)
    end

    let(:invoice) do
      InvoiceService.draft(
        user_id: user_id,
        tenant_id: tenant_id,
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: "AUD",
        due_date: current_date + 30.days,
        line_items: [{
          description: "Chair",
          unit_amount: {
            amount: BigDecimal("100.00"),
            currency_code: "AUD" },
          quantity: 1
        }, {
          description: "Table",
          unit_amount: {
            amount: BigDecimal("300.00"),
            currency_code: "AUD" },
          quantity: 3 } ])
    end

    let(:invoice_model) do
      Invoice.where(tenant_id: tenant_id).find_by!(id: invoice[:id])
    end

    let(:event_model) do
      InvoiceDraftedEvent
        .where(tenant_id: tenant_id).find_by!(id: invoice[:events].last[:id])
    end

    describe '.draft' do
      it 'creates invoice' do
        expect(invoice_model).to have_attributes(
          organisation_id: organisation.id,
          contact_id: contact.id,
          status: Invoice::Status::DRAFTED,
          currency_code: "AUD",
          due_date: current_date + 30.days,
          line_items: match_array([
            have_attributes(
              description: "Chair",
              unit_amount_amount: BigDecimal("100.00"),
              unit_amount_currency_code: "AUD",
              quantity: 1),
            have_attributes(
              description: "Table",
              unit_amount_amount: BigDecimal("300.00"),
              unit_amount_currency_code: "AUD",
              quantity: 3) ]),
          sub_total_amount: BigDecimal("1000.00"),
          sub_total_currency_code: "AUD")
      end

      it 'creates drafted event' do
        expect(event_model.body).to eq({
          'invoice' => {
            'id' => invoice[:id],
            'organisation_id' => organisation.id,
            'contact_id' => contact.id,
            'status' => Invoice::Status::DRAFTED,
            'currency_code' => "AUD",
            'due_date' => (current_date + 30.days ).to_s,
            'line_items' => [{
              'description' => "Chair",
              'unit_amount_amount' => BigDecimal("100.00").to_s,
              'unit_amount_currency_code' => "AUD",
              'quantity' => 1
            }, {
              'description' => "Table",
              'unit_amount_amount' => BigDecimal("300.00").to_s,
              'unit_amount_currency_code' => "AUD",
              'quantity' => 3 }],
            'sub_total' => {
              'amount' => BigDecimal('1000.00').to_s,
              'currency_code' => "AUD" } } })
      end

      it 'associates event with model' do
        expect(invoice_model.events.last.id).to eq(invoice[:events].last[:id])
      end
    end
  end
end
