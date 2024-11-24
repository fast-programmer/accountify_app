module Accountify
  class InvoiceController < AccountifyController
    def create
      id, event_id = Invoice.draft(
        user_id: user_id,
        tenant_id: tenant_id,
        organisation_id: params[:organisation_id],
        contact_id: params[:contact_id],
        currency_code: params[:currency_code],
        due_date: params[:due_date],
        line_items: params[:line_items])

      render json: { id: id, event_id: event_id }, status: :created
    end

    def show
      invoice = Invoice.find_by_id(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: invoice
    end

    def update
      event_id = Invoice.update(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id],
        organisation_id: params[:organisation_id],
        contact_id: params[:contact_id],
        due_date: params[:due_date],
        line_items: params[:line_items])

      render json: { event_id: event_id }, status: :ok
    end

    def destroy
      event_id = Invoice.delete(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end

    def issue
      event_id = Invoice.issue(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end

    def paid
      event_id = Invoice.paid(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end

    def void
      event_id = Invoice.void(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end
  end
end
