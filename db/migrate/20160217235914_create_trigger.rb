class CreateTrigger < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.integer :crud_action_id
      t.string :klass
      t.timestamps
    end
    create_table :conditions do |t|
      t.string :operator
      t.timestamps
    end
    create_table :condition_trigger_joins do |t|
      t.integer :trigger_id
      t.integer :condition_id
      t.string :operator, default: "||"
      t.timestamps
    end
    create_table :actions do |t|
      t.integer :trigger_id
      t.integer :crud_action_id
      t.string :klass
      t.timestamps
    end
    create_table :crud_actions do |t|
      t.string :name
    end
    create_table :field_value_pairs do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :identifier
      t.string :field
      t.string :value
    end    
  end
end
