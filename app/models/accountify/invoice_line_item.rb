module Accountify
  class InvoiceLineItem < ActiveRecord::Base
    self.table_name = 'accountify_invoice_line_items'
  end
end
