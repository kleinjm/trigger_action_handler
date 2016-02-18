require 'spec_helper'

describe TriggerHandler do

  before do
    ["create", "update", "delete"].map{ |crud| CrudAction.create(name: crud) }
  end

  describe ".perform" do
    it "raise error on invalid record" do
      expect{TriggerHandler.perform(nil, "create")}.to raise_error(RuntimeError)
    end
    it "raise error on invalid transaction type" do
      deal = create :deal
      expect{TriggerHandler.perform(deal, "bad")}.to raise_error(RuntimeError)
    end

    it "if Deal is updated and new deal stage is a 'dead' stage, update tasks and event to mark as 'cancelled'" do
      deal = create :deal                                 # trigger object
      task = create :task, deal: deal                     # changing object
      event = create :event, deal: deal                   # changing object

      deal_trigger = create :deal_trigger                 # trigger

      # condition
      dead_stage = create :deal_stage, name: "dead", dead: true
      condition_pair = create :field_value_pair, field: "current_stage_id", value: dead_stage.id
      condition = create :condition, trigger: deal_trigger
      
      # action to perform
      cancelled_status = create :task_status, name: "cancelled"
      task_action = create :action, trigger: deal_trigger, klass: "Task"
      task_find_pair = create :field_value_pair, field: "deal_id", value: deal.id, owner: task_action
      task_change_pair = create :field_value_pair, field: "task_status_id", value: cancelled_status.id, owner: task_action

      # action to perform
      event_action = create :action, trigger: deal_trigger, klass: "Event"
      event_find_pair = create :field_value_pair, field: "deal_id", value: deal.id, owner: event_action
      event_change_pair = create :field_value_pair, field: "cancelled", value: true, owner: event_action

      # check defaults
      expect(task.task_status_id).to eq nil
      expect(event.cancelled).to eq false

      # this will fire TriggerHandler.perform from the GlobalObserver
      deal.update_attribute(:current_stage_id, dead_stage.id)

      task.reload
      event.reload
      expect(task.task_status_id).to eq cancelled_status.id
      expect(event.cancelled).to eq true
    end
  end
end