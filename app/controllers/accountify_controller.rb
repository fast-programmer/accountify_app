class AccountifyController < ActionController::API
  around_action :around_action

  attr_reader :current_iam_api_key
  attr_reader :current_iam_user
  attr_reader :current_iam_tenant

  private

  def around_action
    auth_header = request.headers['Authorization']
    scheme, token = auth_header.split(' ')

    @current_iam_api_key = Iam::Models::ApiKey.find_by!(key: request.headers['Authorization'], active: true, expires_at: nil)
    @current_iam_user = Iam::Models::User.find_by!(id: @current_iam_api_key.user_id)
    @current_iam_tenant = Iam::Models::Tenant.find_by(subdomain: request.subdomain)

    yield
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end
end
