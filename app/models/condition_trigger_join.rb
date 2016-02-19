class ConditionTriggerJoin < ActiveRecord::Base
  belongs_to :trigger
  belongs_to :condition

  validates_presence_of :trigger_id, :condition_id

  OPERATORS = ["&&", "||"]

  # based on the join operator and each condition's evaluation, return a boolean specifying if all condtions are met
  def self.meets_condtions?(joins, item)
    return true if joins.blank?  # the action should run if there are no conditions
    total_res = false
    joins.each do |join|
      cond = join.condition
      res = eval("item.#{cond.field_value_pair.field} #{cond.operator} #{cond.field_value_pair.value}")
      total_res = eval("#{total_res} #{join.operator} #{res}")
    end
    return total_res
  end
end