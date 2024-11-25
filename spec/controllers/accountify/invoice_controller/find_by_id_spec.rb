require 'rails_helper'

module Accountify
  RSpec.describe InvoiceController, type: :controller do
    let(:current_date) { Date.today }

    let(:user_id) { 1 }

    let(:tenant_id) { 1 }

    let(:organisation) do
      create(:accountify_organisation, tenant_id: tenant_id)
    end

    let(:contact) do
      create(:accountify_contact,
        tenant_id: tenant_id,
        organisation_id: organisation.id)
    end

    before do
      request.headers['X-User-Id'] = user_id
      request.headers['X-Tenant-Id'] = tenant_id
    end

    let(:invoice) do
      create(:accountify_invoice,
        tenant_id: tenant_id,
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: "AUD",
        status: Invoice::Status::DRAFT,
        due_date: current_date + 30.days,
        sub_total_amount: BigDecimal("600.00"),
        sub_total_currency_code: "AUD",
        line_items: [
          build(:accountify_invoice_line_item,
            description: "Leather Boots",
            unit_amount_amount: BigDecimal("300.0"),
            unit_amount_currency_code: "AUD",
            quantity: 2),
          build(:accountify_invoice_line_item,
            description: "White Pants",
            unit_amount_amount: BigDecimal("400.0"),
            unit_amount_currency_code: "AUD",
            quantity: 3) ])
    end

    let(:response) { get :show, params: { id: invoice.id } }

    let!(:response_body_json) { JSON.parse(response.body) }

    describe 'GET #show' do
      it 'returns 200 with correct body' do
        expect(response).to have_http_status(:ok)

        expect(response_body_json).to eq({
          "contact_id" => contact.id,
          "currency_code" => "AUD",
          "due_date" => (current_date + 30.days).to_s,
          "id" => invoice.id,
          "line_items" => [{
            "description" => "Leather Boots",
            "quantity" => 2,
            "unit_amount" => {
              "amount" => "300.0",
              "currency_code" => "AUD" }
            }, {
            "description" => "White Pants",
            "quantity" => 3,
            "unit_amount" => {
              "amount" => "400.0",
              "currency_code" => "AUD" } } ],
          "organisation_id" => organisation.id,
          "status" => "draft",
          "sub_total" => {
            "amount" => "600.0",
            "currency_code" => "AUD" },
          "events" => []})
      end
    end
  end
end
