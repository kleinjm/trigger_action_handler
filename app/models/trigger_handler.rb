class TriggerHandler
  attr_accessor :item

  def initialize(item, transaction)
    raise ArgumentError, 'TriggerHandler given nil item' if item.blank?
    unless CrudAction.names.include?(transaction)
      raise ArgumentError, 'TriggerHandler given unrecognized transaction'
    end
    @item = item
    @transaction = transaction
  end

  # iterate through any triggers related to the item and transaction.
  # execute the actions where all/any conditions are met
  def perform
    return if triggers.blank?

    # for each trigger matching this item's class
    triggers.each do |trigger|
      # see if any/all conditions match this item's state
      unless ConditionTriggerJoin
             .meets_condtions?(trigger.condition_trigger_joins, item)
        next
      end

      # perform all actions associated with this trigger
      trigger.actions.map do |action|
        perform_crud(fetch_records(action), action)
      end
    end
  end

  # evaluate the given value if it begins with "item"
  def self.evaluate_value(value, item)
    value.starts_with?('item') ? eval(value) : value
  end

  private

  # return the records that match the given lookup field value
  def fetch_records(action)
    klass = action.klass.constantize

    # scope the action if necessary
    unless action.lookup_field_value_pair.blank?
      lookup_value = TriggerHandler
                     .evaluate_value(action.lookup_field_value_pair.value, item)
      field_segments = action.lookup_field_value_pair.field.split('.')

      # a syntax for doing a join within the lookup. This could be extended
      # to handle any number of db_actions by extracting it into a
      # recursive helper method
      if field_segments.count == 3
        db_action, table, field = field_segments
        records =
          eval("#{klass.name}.#{db_action}(:#{table})")
          .where("#{field} = ?", lookup_value)
      else
        records = klass.where("#{field_segments.first} = ?", lookup_value)
      end
    end
    records
  end

  def perform_crud(records, action)
    # build a hash so that the transaction is done in one db call
    field_pairs = FieldValuePair.to_hash(action.change_field_value_pairs, item)
    case action.crud_action.name
    when 'update'
      records.update_all(field_pairs)
    when 'create'
      action.klass.constantize.create(field_pairs)
    when 'destroy'
      records.destroy_all
    end
  end

  # grab all triggers for the given type of object that occur on the
  # given type of transaction
  def triggers
    @_triggers ||= Trigger
                   .joins(:crud_action)
                   .where(klass: item.class.name,
                          crud_actions: { name: @transaction })
  end
end
