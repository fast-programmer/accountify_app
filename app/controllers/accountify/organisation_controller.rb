module Accountify
  class OrganisationController < AccountifyController
    def create
      organisation_id, event_id = Organisation.create(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        name: params[:name])

      render json: { organisation_id: organisation_id, event_id: event_id }, status: :created
    end

    def show
      organisation = Organisation.find_by_id(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: params[:id])

      render json: organisation, status: :ok
    end

    def update
      event_id = Organisation.update(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: params[:id],
        name: params[:name])

      render json: { event_id: event_id }, status: :ok
    end

    def destroy
      event_id = Organisation.delete(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end
  end
end
