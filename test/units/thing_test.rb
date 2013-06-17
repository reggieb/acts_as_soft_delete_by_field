require 'test_helper'
require 'thing'


class ThingTest < ActiveSupport::TestCase

  def test_soft_delete
    thing = Thing.create(:name => 'thing')
    assert_soft_delete_by_field_working_for(thing)
    thing.delete
  end
end
