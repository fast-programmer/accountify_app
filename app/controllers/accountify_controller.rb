class AccountifyController < ActionController::API
  around_action :around_action

  attr_reader :tenant_id

  def user_id
    1
  end

  private

  def around_action
    @tenant_id = request.headers['X-Tenant-Id']

    if @tenant_id
      yield
    else
      render json: { error: 'X-Tenant-Id is required' }, status: :bad_request
    end
  end
end
