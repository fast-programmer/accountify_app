module Accountify
  class ContactController < AccountifyController
    def create
      contact = Contact.create(
        user_id: user_id,
        tenant_id: tenant_id,
        organisation_id: params[:organisation_id],
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email])

      render json: contact, status: :created
    end

    def show
      contact = Contact.find_by_id(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: contact
    end

    def update
      contact = Contact.update(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id],
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email])

      render json: contact, status: :ok
    end

    def destroy
      contact = Contact.delete(
        user_id: user_id,
        tenant_id: tenant_id,
        id: params[:id])

      render json: contact, status: :ok
    end
  end
end
