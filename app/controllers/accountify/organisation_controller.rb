module Accountify
  class OrganisationController < AccountifyController
    def create
      organisation_id, event_id = Organisation.create(
        user_id: user_id,
        tenant_id: tenant_id,
        name: params[:name])

      render json: { organisation_id: organisation_id, event_id: event_id },
        status: :created
    end

    def show
      organisation = Organisation.find_by_id(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: organisation, status: :ok
    end

    def update
      event_id = Organisation.update(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id],
        name: params[:name])

      render json: { event_id: event_id }, status: :ok
    end

    def destroy
      event_id = Organisation.delete(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: { event_id: event_id }, status: :ok
    end
  end
end
