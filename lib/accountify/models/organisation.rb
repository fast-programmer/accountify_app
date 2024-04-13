module Accountify
  module Models
    class Organisation < ActiveRecord::Base
      self.table_name = 'accountify_organisations'
    end
  end
end
