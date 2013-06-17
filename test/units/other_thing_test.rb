require 'test_helper'
require 'other_thing'


class OtherThingTest < ActiveSupport::TestCase

  def test_thing_using_alternative_deletion_field
    thing = OtherThing.create(:name => 'thing')  
    assert_soft_delete_by_field_working_for(thing)
    thing.delete
  end
end
