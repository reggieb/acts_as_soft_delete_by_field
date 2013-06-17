class CreateThing < ActiveRecord::Migration
  def change
    create_table :things do |t|
      t.string :name
      t.datetime :deleted_at
      t.datetime :removed_at
      t.timestamps
    end
  end
end
