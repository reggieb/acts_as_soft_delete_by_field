require 'test_helper'
require 'inheriting_thing'


class InheritingThingTest < ActiveSupport::TestCase

  def test_soft_delete_with_functionality_inherited_from_parent
    thing = InheritingThing.create(:name => 'thing')
    assert_soft_delete_by_field_working_for(thing)
    thing.delete
  end
end
