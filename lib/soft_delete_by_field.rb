module ActiveRecord #:nodoc:
  module Acts #:nodoc:

    module SoftDeleteByField
      DEFAULT_FIELD_NAME = :deleted_at

      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods

        def soft_delete_by_field_name
          @soft_delete_by_field_name
        end

        def acts_as_soft_delete_by_field(field_name = nil)
          attr_accessor :reasons_not_to_delete
          field_name ||= DEFAULT_FIELD_NAME
          @soft_delete_by_field_name = field_name.to_sym
          send :include, SoftDeleteByField::InstanceMethods
          scope :extant, where(["#{(self.class.name.tableize + ".") if self.class.kind_of?(SoftDeleteByField)}#{field_name} IS NULL"])
          scope :deleted, where(["#{(self.class.name.tableize + ".") if self.class.kind_of?(SoftDeleteByField)}#{field_name} IS NOT NULL"])
        end
  
      end

      module InstanceMethods


        # Overwrite this method to add actions that are triggered before soft_delete operates.
        def before_soft_delete

        end

        # Rename this 'delete' if you wish this functionality to replace the
        # default delete behaviour.
        def soft_delete
          before_soft_delete
          unless reasons_not_to_delete?
            update_attribute(soft_delete_by_field_name, Time.now)
            after_soft_delete
            return 'deleted'
          else
            errors.add(:base, "Unable to delete. reasons_not_to_delete returns #{@reasons_not_to_delete || 'true'} for #{inspect}")
          end
        end

        # Overwrite this method to add actions that are triggered after soft_delete operates.
        def after_soft_delete

        end

        # Overwrite this method to add actions that are triggered before recover_soft_deleted operates.
        def before_recover_soft_deleted

        end

        def recover_soft_deleted
          before_recover_soft_deleted
          update_attribute(soft_delete_by_field_name, nil)
          after_recover_soft_deleted
        end

        # Overwrite this method to add actions that are triggered after recover_soft_deleted operates.
        def after_recover_soft_deleted

        end

        def is_deleted?
          send(soft_delete_by_field_name) != nil
        end

        def deleted?
          is_deleted?
        end

        def is_extant?
          !send(soft_delete_by_field_name)
        end

        def extant?
          is_extant?
        end

        # You can either overwrite this method to add methods that prevent soft
        # deletion, or set @reasons_not_to_delete to true. For example, set
        # @reasons_not_to_delete = 'Component needs to be deleted first'
        def reasons_not_to_delete?
          @reasons_not_to_delete
        end

        def deleted_via_soft_delete_by_field_name_at
          send(soft_delete_by_field_name)
        end

        private
        def table_name_modifier
          klass = self.class
          if klass.kind_of?(SoftDeleteByField) and !klass.instance_of(SoftDeleteByField)
            "#{klass.name.tableize}."
          else
            ""
          end
        end

        def soft_delete_by_field_name
          self.class.soft_delete_by_field_name
        end
      end
    end
  end
end
