module Iam
  module Models
    class Tenant < ActiveRecord::Base
      self.table_name = 'iam_tenants'

      VALID_SUBDOMAIN_REGEX = /\A[a-zA-Z0-9]+[a-zA-Z0-9\-]*[a-zA-Z0-9]+\z/

      validates :subdomain,
        presence: true,
        uniqueness: true,
        format: { with: VALID_SUBDOMAIN_REGEX, message: 'must be a valid subdomain' }

      has_many :memberships, class_name: 'Iam::Models::Membership', foreign_key: 'tenant_id'
      has_many :users, through: :memberships, class_name: 'Iam::Models::User'
    end
  end
end
