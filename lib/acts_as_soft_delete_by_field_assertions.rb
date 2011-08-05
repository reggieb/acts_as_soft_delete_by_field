# Provides assertion methods that make it easier to test soft deletion functionality
#
# The soft delete functionality can be tested via:
#
#   class ThingTest < ActiveSupport::TestCase
#
#     def test_soft_delete
#       assert_soft_delete_working_for(Thing.first)
#     end
#
#   end
#
module ActsAsSoftDeleteByFieldAssertions

  def assert_soft_delete_by_field_working_for(item)
    # Using clones, as otherwise other assertions affected
    @starting_number = item.class.count
    assert_before_soft_delete_all_correct_for(item)
    @start_time = Time.now
    item.soft_delete
    assert_extant_working_for(item)
    assert_deleted_working_for(item)
    assert_still_in_database_but_with_deleted_at_set(item)
    assert_soft_deleted(item)
    assert_recover_soft_deleted(item)
    assert_deletion_prevented_if_reasons_not_to_delete_overwritten_with_method_returning_true(item.clone)
    assert_deletion_prevented_if_reasons_not_to_delete_detected(item)
    assert_before_soft_delete(item.clone)
    assert_after_soft_delete(item.clone)
  end
  
  def assert_soft_deleted(item)
    assert_equal(true, item.reload.is_deleted?, error_messages_for(item, "Not deleted: #{item.inspect}"))
  end

  def assert_extant(item)
    deletion_object_details = ". Deletion_object: #{@deletion_objects.inspect}" if @deletion_objects
    assert_equal(true, item.reload.is_extant?,  error_messages_for(item, "Not extant: #{item.inspect}"))
  end

  def assert_get_request_to_delete_raises_error
    login_as User.first
    assert_raise RuntimeError do
      get :delete
    end
  end

  def assert_recover_soft_deleted(item)
    item.recover_soft_deleted
    assert_before_soft_delete_all_correct_for(item)
  end

  def assert_before_soft_delete_all_correct_for(item)
    assert_all_extant(item)
    assert_extant_includes(item)
    assert_none_soft_deleted(item)
    assert_extant(item)
  end

  def assert_extant_includes(item)
    assert item.class.extant.include?(item)
  end

  def assert_all_extant(item)
    assert_equal item.class.count, item.class.extant.count
  end

  def assert_none_soft_deleted(item)
    assert_equal 0, item.class.deleted.count
  end

  def assert_extant_working_for(item)
    assert_equal @starting_number - 1, item.class.extant.count
    assert !item.class.extant.include?(item)
  end

  def assert_deleted_working_for(item)
    assert_equal 1, item.class.deleted.count
    assert_equal item, item.class.deleted.first
  end

  def assert_still_in_database_but_with_deleted_at_set(item)
    assert_object_still_in_database(item)
    assert_deleted_at_set_as_time_after_test_started_for(item)
  end

  def assert_deleted_at_set_as_time_after_test_started_for(object)
    assert object.deleted_via_soft_delete_by_field_name_at >= @start_time, "Deletion occured before test was run (#{object.deleted_via_soft_delete_by_field_name_at})"
  end

  def assert_object_still_in_database(object)
    assert_equal object, object.class.find(object.id)
  end

  def create_soft_deletion_objects(object, source_path)
    @source_path = source_path
    @object_class = object.class.to_s
    @object_id = object.id.to_s
    @deletion_objects = {
        :source_path => @source_path,
        :object_class => @object_class,
        :object_id => @object_id
    }
  end

  def assert_soft_deletion_via_delete_action(object, path)
    create_deletion_objects_and_pass_to_delete(object, path)
    assert_redirection_to_path(@source_path)
    assert_soft_deleted(object)
  end

  def assert_failure_to_soft_delete_via_delete_action(object, path)
    create_deletion_objects_and_pass_to_delete(object, path)
    assert_redirection_to_path(@source_path)
    assert_extant(object)
  end

  def create_deletion_objects_and_pass_to_delete(object, path)
    create_soft_deletion_objects(object, path)
    @deletion_objects
    post :delete, @deletion_objects
  end

  def assert_undeletion_via_recover_soft_deleted_action(object, path)
    object.soft_delete
    create_deletion_objects_and_pass_to_recover_soft_deleted(object, path)
    assert_redirection_to_path(@source_path)
    assert_extant(object.reload)
  end
  
  def create_deletion_objects_and_pass_to_recover_soft_deleted(object, path)
    create_soft_deletion_objects(object, path)
    @deletion_objects
    post :recover_soft_deleted, @deletion_objects
  end

  def assert_deletion_prevented_if_reasons_not_to_delete_overwritten_with_method_returning_true(item)
    if model_has_custom_reason_not_to_delete_defined(item)
      # This test not valid in this case
    else
      assert_soft_deletion_working(item)
      method_to_add_to_item = <<EOF

  def reasons_not_to_delete?
    true
  end

EOF

      item.class_eval(method_to_add_to_item)
      assert_reasons_not_to_delete_prevents_soft_deletion(item)
    end
  end

  def assert_deletion_prevented_if_reasons_not_to_delete_detected(item)
    if model_has_custom_reason_not_to_delete_defined(item)
      # This test not valid in this case
    else
      assert_soft_deletion_working(item)
      initial_reasons_not_to_delete = item.reasons_not_to_delete
      item.reasons_not_to_delete = "Don't delete"
      assert_reasons_not_to_delete_prevents_soft_deletion(item)
      item.reasons_not_to_delete = initial_reasons_not_to_delete
    end
  end

  def assert_before_soft_delete(item)
    message = "Hello world"
    assert_soft_deletion_working(item)
    assert(!item.respond_to?(:goodbye))
    method_to_add_to_item = <<EOF

  def goodbye
    '#{message}'
  end

EOF
    item.class_eval(method_to_add_to_item)
    item.soft_delete
    assert item.is_deleted?, 'Item not deleted'
    assert_equal message, item.goodbye
  end

  def assert_after_soft_delete(item)
    message = 'Hello there'
    assert_soft_deletion_working(item)
    assert(!item.respond_to?(:hello))
    method_to_add_to_item = <<EOF

  def hello
    '#{message}'
  end

EOF
    item.class_eval(method_to_add_to_item)
    item.soft_delete
    assert item.is_deleted?, 'Item not deleted'
    assert_equal message, item.hello
  end


  private
  def error_messages_for(item, first_message)
    error_messages = [first_message]
    error_messages << item.errors.full_messages unless item.errors.empty?
    error_messages << "Flash: #{@request.session['flash'].inspect}" if @request
    error_messages << "Deletion_object: #{@deletion_objects.inspect}" if @deletion_objects
    error_messages.join(". ")
  end

  def assert_extant_at_start_of_test(item)
    assert(item.is_extant?, "Item must be extant at start of test #{item.inspect}")
  end

  def assert_reasons_not_to_delete_prevents_soft_deletion(item)
    item.soft_delete
    assert(item.is_extant?, "Item was deleted in spite of reasons_not_to_delete? being true")
    assert_errors_on_base(item)
  end

  def assert_soft_deletion_working(item)
    item.soft_delete
    assert(item.is_deleted?, "Item should be deleted. item: #{item.inspect}")
    item.recover_soft_deleted
    assert(item.is_extant?, "Item should be extant")
  end

  def model_has_custom_reason_not_to_delete_defined(item)
     item.class.private_method_defined?('reasons_not_to_delete?') or (item.reasons_not_to_delete != item.reasons_not_to_delete?)
  end

  def assert_errors_on_base(object)
    assert(object.errors[:base],
      "Should have Errors on base detected for object: #{object.inspect}"
    )
  end

end

ActiveSupport::TestCase.send(:include, ActsAsSoftDeleteByFieldAssertions)