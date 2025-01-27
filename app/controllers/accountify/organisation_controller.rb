module Accountify
  class OrganisationController < AccountifyController
    def create
      organisation = OrganisationService.create(
        user_id: user_id,
        tenant_id: tenant_id,
        name: params[:name])

      render json: organisation, status: :created
    end

    def show
      organisation = OrganisationService.find_by_id(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: organisation, status: :ok
    end

    def update
      organisation = OrganisationService.update(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id],
        name: params[:name])

      render json: organisation, status: :ok
    end

    def destroy
      organisation = OrganisationService.delete(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: organisation, status: :ok
    end
  end
end
