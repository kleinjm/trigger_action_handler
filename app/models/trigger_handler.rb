class TriggerHandler

  def self.perform(item)
    raise "TriggerHandler given nil item" if item.blank?

    triggers = Trigger.where(klass: item.class.name)

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

              # update all fields via the change pairs
              action.change_field_val_pair.each do |pair|


                # TODO: build a hash here from a loop so this is doen in one db call

                records.update_all(pair.field.parameterize.underscore.to_sym => pair.value)
              end
            end
          end
        end
      end

    end


    # 1. If Deal is updated and new deal stage is a "dead" stage, update tasks and event to mark as "cancelled"
    # doesn't account for crud actions right now

    # 2. Lead Schedules showing for property and is assigned to an agent, create an event for that agent for the showing request time


  end
end