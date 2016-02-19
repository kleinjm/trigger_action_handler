class TriggerHandler

  attr_accessor :item

  def initialize(item, transaction)
    @item = item
    @transaction = transaction
  end

  def perform
    raise "TriggerHandler given nil item" if item.blank?
    raise "TriggerHandler given unrecognized transaction" unless CrudAction.names.include?(@transaction)

    # grab all triggers for the given type of object that occur on the given type of transaction
    triggers = Trigger.joins(:crud_action).where(klass: item.class.name, crud_actions: { name: transaction })

    unless triggers.blank?
      # for each trigger matching this item's class
      triggers.each do |trigger|

        # see if any/all conditions match this item's state
        if ConditionTriggerJoin.meets_condtions?(trigger.condition_trigger_joins, item)
          # perform all actions associated with this trigger
          trigger.actions.each do |action|
            perform_crud(fetch_records(action, item), action, item)
          end
        end
      end
    end
  end

  # evaluate the given value if it begins with "item"
  def self.evaluate_value(value, item)
    value.starts_with?("item") ? eval(value) : value
  end

  private

  # return the records that match the given lookup field value
  def self.fetch_records(action, item)
    klass = action.klass.constantize

    # scope the action if necessary
    unless action.lookup_field_value_pair.blank?
      lookup_value = evaluate_value(action.lookup_field_value_pair.value, item)
      field_segments = action.lookup_field_value_pair.field.split(".")

      # a syntax for doing a join within the lookup. This could be extended to handle 
      # any number of db_actions by extracting it into a  recursive helper method
      if field_segments.count == 3
        db_action, table, field = field_segments
        records = eval("#{klass.name}.#{db_action}(:#{table})").where("#{field} = ?", lookup_value)
      else
        records = klass.where("#{field_segments.first} = ?", lookup_value)
      end
    end
    return records
  end

  def self.perform_crud(records, action, item)
    # build a hash so that the transaction is done in one db call
    field_pairs = FieldValuePair.hashify(action.change_field_value_pairs, item)
    case action.crud_action.name
    when "update"
      records.update_all(field_pairs)
    when "create"
      action.klass.constantize.create(field_pairs)
    when "destroy"
      records.destroy_all
    end

  end
end