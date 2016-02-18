class TriggerHandler

  def self.perform(item, transaction)
    raise "TriggerHandler given nil item" if item.blank?
    raise "TriggerHandler given unrecognized transaction" unless CrudAction.names.include?(transaction)

    # grab all triggers for the given type of object that occur on the given type of transaction
    triggers = Trigger.joins(:crud_action).where(klass: item.class.name, crud_actions: { name: transaction })

    unless triggers.blank?
      # for each trigger matching this item's class
      triggers.each do |trigger|
        # see if any conditions match this item's state
        trigger.conditions.each do |cond|
          if eval("item.#{cond.field_value_pair.field} #{cond.operator} #{cond.field_value_pair.value}")
            # perform all actions associated with this trigger
            trigger.actions.each do |action|
              klass = action.klass.constantize
              lookup_field = action.lookup_field_val_pair.field
              lookup_value = action.lookup_field_val_pair.value
              
              records = klass.where("#{lookup_field} = ?", lookup_value)

              perform_crud(records, action, action.crud_action.name)
            end
          end
        end
      end

    end


#     # 1. If Deal is updated and new deal stage is a "dead" stage, update tasks and event to mark as "cancelled"
#     # doesn't account for crud actions right now

#     # 2. Lead Schedules showing for property and is assigned to an agent, create an event for that agent for the showing request time


  end

  private

  def self.perform_crud(records, action, crud)
    case crud
    when "update"
      # build a hash here so that the update is done in one db call
      field_pairs = FieldValuePair.hashify(action.change_field_val_pairs)
      records.update_all(field_pairs)                
    end

  end
end