module Iam
  module Models
    class Membership < ActiveRecord::Base
      self.table_name = 'iam_memberships'

      belongs_to :user, class_name: 'Iam::Models::User', foreign_key: 'user_id'
      belongs_to :tenant, class_name: 'Iam::Models::Tenant', foreign_key: 'tenant_id'
    end
  end
end
