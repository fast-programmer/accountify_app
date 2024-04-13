module Accountify
  module Models
    class Organisation < ActiveRecord::Base
      self.table_name = 'accountify_organisations'

      has_many :events, as: :eventable, class_name: 'Models::Event'
    end
  end
end
