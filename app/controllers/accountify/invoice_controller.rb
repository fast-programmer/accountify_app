module Accountify
  class InvoiceController < AccountifyController
    def create
      invoice = InvoiceService.draft(
        user_id: user_id,
        tenant_id: tenant_id,
        organisation_id: params[:organisation_id],
        contact_id: params[:contact_id],
        currency_code: params[:currency_code],
        due_date: params[:due_date],
        line_items: params[:line_items])

      render json: invoice, status: :created
    end

    def show
      invoice = InvoiceService.find_by_id(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: invoice
    end

    def update
      invoice = InvoiceService.update(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id],
        organisation_id: params[:organisation_id],
        contact_id: params[:contact_id],
        due_date: params[:due_date],
        line_items: params[:line_items])

      render json: invoice, status: :ok
    end

    def destroy
      invoice = InvoiceService.delete(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: invoice, status: :ok
    end

    def issue
      invoice = InvoiceService.issue(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: invoice, status: :ok
    end

    def paid
      invoice = InvoiceService.paid(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: invoice, status: :ok
    end

    def void
      invoice = InvoiceService.void(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: invoice, status: :ok
    end
  end
end
