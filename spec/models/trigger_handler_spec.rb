require 'spec_helper'

describe TriggerHandler do


  describe ".perform" do
    it "raise error on invalid record" do
      expect{TriggerHandler.perform(nil)}.to raise_error(RuntimeError)
    end

    it "updates the records" do
      deal = create :deal
      task = create :task, deal: deal
      event = create :event, deal: deal
      deal_trigger = create :deal_trigger
      condition = create :condition, trigger: deal_trigger
      
      task_action = create :action, trigger: deal_trigger, klass: "Task"
      task_find_pair = create :field_value_pair, field: "deal_id", value: deal.id, owner: task_action
      task_change_pair = create :field_value_pair, field: "task_status_id", value: 1, owner: task_action

      event_action = create :action, trigger: deal_trigger, klass: "Event"
      event_find_pair = create :field_value_pair, field: "deal_id", value: deal.id, owner: event_action
      event_change_pair = create :field_value_pair, field: "cancelled", value: true, owner: event_action


      deal.update_attribute(:current_stage_id, 1)

      expect(task.task_status_id).to eq nil
      expect(event.cancelled).to eq false

      TriggerHandler.perform(deal)

      task.reload
      event.reload
      expect(task.task_status_id).to eq 1
      expect(event.cancelled).to eq true
    end
  end
end