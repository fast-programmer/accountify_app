module Accountify
  class InvoiceController < AccountifyController
    def create
      id, event_id = Invoice.draft(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        organisation_id: params[:organisation_id],
        contact_id: params[:contact_id],
        currency_code: params[:currency_code],
        due_date: params[:due_date],
        line_items: params[:line_items])

      render json: { id: id, event_id: event_id }, status: :created
    end

    def show
      invoice = Invoice.find_by_id(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: params[:id])

      render json: invoice
    end

    def update
      event_id = Invoice.update(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: params[:id],
        organisation_id: params[:organisation_id],
        contact_id: params[:contact_id],
        due_date: params[:due_date],
        line_items: params[:line_items])

      render json: { event_id: event_id }, status: :ok
    end

    def destroy
      event_id = Invoice.delete(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end

    def issue
      event_id = Invoice.issue(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end

    def void
      event_id = Invoice.void(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end
  end
end
