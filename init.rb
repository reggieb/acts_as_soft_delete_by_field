$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'soft_delete_by_field'

class ActiveSupport::TestCase
  include ActsAsSoftDeleteByFieldAssertions
end

class ActiveRecord::Base
  include ActiveRecord::Acts::SoftDeleteByField
end
