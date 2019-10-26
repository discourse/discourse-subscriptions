# frozen_string_literal: true

module DiscoursePatrons
  class Customer < ActiveRecord::Base
    self.table_name = "discourse_patrons_customers"
  end
end
