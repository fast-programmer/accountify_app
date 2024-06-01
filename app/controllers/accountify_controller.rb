class AccountifyController < ActionController::API
  around_action :around_action

  attr_reader :iam_tenant_id

  def iam_user_id
    1
  end

  private

  def around_action
    @iam_tenant_id = request.headers['X-Iam-Tenant-Id']

    if @iam_tenant_id
      yield
    else
      render json: { error: 'X-Iam-Tenant-Id is required' }, status: :bad_request
    end
  end
end
