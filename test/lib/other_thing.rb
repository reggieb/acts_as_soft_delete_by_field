
class OtherThing < ActiveRecord::Base
  self.table_name = "things"

  acts_as_soft_delete_by_field :removed_at
end
