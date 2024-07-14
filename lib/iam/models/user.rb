module Iam
  module Models
    class User < ActiveRecord::Base
      self.table_name = 'iam_users'

      has_secure_password

      validates :email, presence: true, uniqueness: true

      has_many :memberships, class_name: 'Iam::Models::Membership', foreign_key: 'user_id'
      has_many :tenants, through: :memberships, class_name: 'Iam::Models::Tenant'
    end
  end
end
