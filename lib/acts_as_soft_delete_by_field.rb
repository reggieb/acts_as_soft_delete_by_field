require 'soft_delete_by_field'
require 'acts_as_soft_delete_by_field_assertions'

ActiveRecord::Base.send(:include, ActiveRecord::Acts::SoftDeleteByField)
ActiveSupport::TestCase.send(:include, ActsAsSoftDeleteByFieldAssertions)