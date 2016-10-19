describe TriggerHandler do
  before :all do
    %w(create update destroy).each { |crud| CrudAction.create(name: crud) }
  end

  let(:create_crud) { CrudAction.find_by_name('create') }
  let(:update_crud) { CrudAction.find_by_name('update') }
  let(:destroy_crud) { CrudAction.find_by_name('destroy') }

  let(:active_status) { create :lead_status, name: 'Active' }
  let(:dead_status) { create :lead_status, name: 'Dead' }
  let(:inactive_status) { create :lead_status, name: 'Inactive' }

  describe '.perform' do
    it 'raise error on invalid record' do
      expect do
        TriggerHandler.new(nil, 'create')
      end.to raise_error(ArgumentError)
    end

    it 'raise error on invalid transaction type' do
      deal = create :deal
      expect do
        TriggerHandler.new(deal, 'bad')
      end.to raise_error(ArgumentError)
    end

    it "Deal is updated and new deal stage is a 'dead' stage, update tasks " \
       "and event to mark as 'cancelled'" do
      deal = create :deal                                 # trigger object
      task = create :task, deal: deal                     # changing object
      event = create :event, deal: deal                   # changing object

      trigger = create :trigger, klass: 'Deal', crud_action: update_crud

      # condition
      dead_stage = create :deal_stage, name: 'dead', dead: true
      condition = create :condition
      condition.create_field_value_pair(
        field: 'current_stage_id', value: dead_stage.id
      )

      # condition trigger join (default operator is OR)
      create :condition_trigger_join, trigger: trigger, condition: condition

      # action to perform
      cancelled_status = create :task_status, name: 'cancelled'
      task_action = create :action, trigger: trigger, klass: 'Task'
      task_action.create_lookup_field_value_pair(
        field: 'deal_id', value: 'item.id', identifier: 'lookup'
      )
      task_action.change_field_value_pairs.create(
        field: 'task_status_id',
        value: cancelled_status.id,
        identifier: 'change'
      )

      # action to perform
      event_action = create :action, trigger: trigger, klass: 'Event'
      event_action.create_lookup_field_value_pair(
        field: 'deal_id', value: 'item.id', identifier: 'lookup'
      )
      event_action.change_field_value_pairs.create(
        field: 'cancelled', value: true, identifier: 'change'
      )

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

    it 'Lead Schedules showing for property and is assigned to an agent, ' \
       'create an event for that agent for the showing request' do
      trigger = create :trigger, klass: 'Showing', crud_action: create_crud

      # condition
      condition = create :condition, operator: '!='
      condition.create_field_value_pair(field: 'agent_id', value: 'nil')

      # condition trigger join (default operator is OR)
      create :condition_trigger_join, trigger: trigger, condition: condition

      # actions to perform
      event_action = create(
        :action, trigger: trigger, klass: 'Event', crud_action: create_crud
      )
      event_action.change_field_value_pairs.create(
        field: 'assignee_id', value: 'item.agent.id', identifier: 'change'
      )
      # assuming the assignee is the creator when this trigger
      # handling is automatic
      event_action.change_field_value_pairs.create(
        field: 'creator_id', value: 'item.agent.id', identifier: 'change'
      )
      event_action.change_field_value_pairs.create(
        field: 'name', value: 'Property Showing', identifier: 'change'
      )

      # check defaults
      expect(Event.count).to eq 0
      expect(Showing.count).to eq 0

      # this will fire TriggerHandler.perform from the GlobalObserver
      showing = create :showing, property_id: 5 # trigger object

      expect(Showing.count).to eq 1
      expect(Event.count).to eq 1
      event = Event.where(assignee: showing.agent.id).first
      expect(event.name).to eq 'Property Showing'
    end

    it 'Lead contacts agent, create task to respond to that inquiry' do
      trigger = create :trigger, klass: 'AgentContact', crud_action: create_crud

      # actions to perform
      task_action = create(
        :action, trigger: trigger, klass: 'Task', crud_action: create_crud
      )
      task_action.change_field_value_pairs.create(
        field: 'assignee_id', value: 'item.agent_id', identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'creator_id', value: 'item.agent_id', identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'lead_id', value: 'item.lead_id', identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'name', value: 'Follow up with inquiry', identifier: 'change'
      )

      # check defaults
      expect(AgentContact.count).to eq 0
      expect(Task.count).to eq 0

      # this will fire TriggerHandler.perform from the GlobalObserver
      agent_contact = create :agent_contact

      expect(AgentContact.count).to eq 1
      expect(Task.count).to eq 1
      task = Task.where(assignee: agent_contact.agent.id).first
      expect(task.name).to eq 'Follow up with inquiry'
    end

    it 'Deal created for lead, add event for projected closing date' do
      trigger = create :trigger, klass: 'Deal', crud_action: create_crud

      # actions to perform
      event_action = create(
        :action, trigger: trigger, klass: 'Event', crud_action: create_crud
      )
      event_action.change_field_value_pairs.create(
        field: 'assignee_id', value: 'item.agent_id', identifier: 'change'
      )
      event_action.change_field_value_pairs.create(
        field: 'creator_id', value: 'item.agent_id', identifier: 'change'
      )
      event_action.change_field_value_pairs.create(
        field: 'lead_id', value: 'item.lead_id', identifier: 'change'
      )
      event_action.change_field_value_pairs.create(
        field: 'deal_id', value: 'item.id', identifier: 'change'
      )
      event_action.change_field_value_pairs.create(
        field: 'start_at', value: 'item.proj_closing_date', identifier: 'change'
      )
      event_action.change_field_value_pairs.create(
        field: 'name', value: 'Projected deal closing', identifier: 'change'
      )

      # check defaults
      expect(Deal.count).to eq 0
      expect(Event.count).to eq 0

      # this will fire TriggerHandler.perform from the GlobalObserver
      deal = create :deal

      expect(Deal.count).to eq 1
      expect(Event.count).to eq 1
      event = Event.where(assignee: deal.agent.id).first
      expect(event.name).to eq 'Projected deal closing'
      expect(event.assignee).to eq deal.agent
      expect(event.lead).to eq deal.lead
      expect(event.deal).to eq deal
      expect(event.start_at).to eq deal.proj_closing_date
    end

    it 'Deal created for lead, add task to complete Purchase and Sale ' \
       'agreement by (due_date) ps_date' do
      trigger = create :trigger, klass: 'Deal', crud_action: create_crud

      # actions to perform
      task_action = create(
        :action, trigger: trigger, klass: 'Task', crud_action: create_crud
      )
      task_action.change_field_value_pairs.create(
        field: 'assignee_id', value: 'item.agent_id', identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'creator_id', value: 'item.agent_id', identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'lead_id', value: 'item.lead_id', identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'due_date', value: 'item.ps_date', identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'name', value: 'Complete Purchase and Sale agreement', identifier: 'change'
      )

      # check defaults
      expect(Deal.count).to eq 0
      expect(Task.count).to eq 0

      # this will fire TriggerHandler.perform from the GlobalObserver
      deal = create :deal

      expect(Deal.count).to eq 1
      expect(Task.count).to eq 1
      task = Task.where(assignee: deal.agent.id).first
      expect(task.name).to eq 'Complete Purchase and Sale agreement'
      expect(task.assignee).to eq deal.agent
      expect(task.lead).to eq deal.lead
      expect(task.due_date).to eq deal.ps_date
    end

    it 'Lead signed up, create task to followup with lead' do
      trigger = create :trigger, klass: 'Lead', crud_action: create_crud

      # actions to perform
      task_action = create(
        :action, trigger: trigger, klass: 'Task', crud_action: create_crud
      )

      # NOTE: This a requirements discovery point.
      #       Do we want to write functionality to randomly assign?
      # Assign to whoever has the least tasks? Or some other method?
      # The other option is to remove the required field validation.
      # I would discuss all these possibilities with the steakholder(s).
      task_action.change_field_value_pairs.create(
        field: 'assignee_id', value: 1, identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'creator_id', value: 1, identifier: 'change'
      )

      task_action.change_field_value_pairs.create(
        field: 'lead_id', value: 'item.id', identifier: 'change'
      )
      task_action.change_field_value_pairs.create(
        field: 'name', value: 'Followup with Lead', identifier: 'change'
      )

      # check defaults
      expect(Lead.count).to eq 0
      expect(Task.count).to eq 0

      # this will fire TriggerHandler.perform from the GlobalObserver
      lead = create :lead

      expect(Lead.count).to eq 1
      expect(Task.count).to eq 1
      task = Task.where(assignee: 1).first
      expect(task.name).to eq 'Followup with Lead'
      expect(task.assignee_id).to eq 1
      expect(task.lead).to eq lead
    end

    it 'Unassigned lead contacts agent, assign that lead to that agent' do
      lead = create :lead

      trigger = create :trigger, klass: 'AgentContact', crud_action: create_crud

      # NOTE: This is an interesting case where we are looking at a value
      # through a relationship
      condition = create :condition
      condition.create_field_value_pair(field: 'lead.agent_id', value: 'nil')

      # condition trigger join (default operator is OR)
      create :condition_trigger_join, trigger: trigger, condition: condition

      # actions to perform
      lead_action = create(
        :action, trigger: trigger, klass: 'Lead', crud_action: update_crud
      )
      lead_action.create_lookup_field_value_pair(
        field: 'id', value: 'item.lead_id', identifier: 'lookup'
      )
      lead_action.change_field_value_pairs.create(
        field: 'agent_id', value: 'item.agent_id', identifier: 'change'
      )

      # check defaults
      expect(AgentContact.count).to eq 0
      expect(lead.agent).to eq nil

      # this will fire TriggerHandler.perform from the GlobalObserver
      agent_contact = create :agent_contact, lead: lead

      lead.reload
      expect(AgentContact.count).to eq 1
      expect(lead.agent).to eq agent_contact.agent
    end

    it 'Deal actual closing date changes, update event dates' do
      deal = create :deal, actual_closing_date: 1.week.ago
      event =
        create :event, deal: deal, start_at: 1.week.ago, end_at: 1.week.ago

      trigger = create :trigger, klass: 'Deal', crud_action: update_crud

      # actions to perform
      event_action = create(
        :action, trigger: trigger, klass: 'Event', crud_action: update_crud
      )
      event_action.create_lookup_field_value_pair(
        field: 'deal_id', value: 'item.id', identifier: 'lookup'
      )
      event_action.change_field_value_pairs.create(
        field: 'start_at', value: 'item.actual_closing_date',
        identifier: 'change'
      )
      event_action.change_field_value_pairs.create(
        field: 'end_at', value: 'item.actual_closing_date', identifier: 'change'
      )

      # this will fire TriggerHandler.perform from the GlobalObserver
      deal.update_attribute(:actual_closing_date, 2.days.from_now)

      event.reload
      expect(event.start_at).to eq 2.days.from_now.to_date
      expect(event.end_at).to eq 2.days.from_now.to_date
    end

    it "Lead status changes to 'Dead' or 'Inactive', remove from marketing lists" do
      lead = create :lead, lead_status: active_status
      create :marketing_list_lead, lead: lead

      trigger = create :trigger, klass: 'Lead', crud_action: update_crud

      # NOTE: In this case, 2 conditions can cause this.
      #       The operator in the join is OR by default
      condition1 = create :condition
      condition1.create_field_value_pair(
        field: 'lead_status_id', value: dead_status.id
      )
      condition2 = create :condition
      condition2.create_field_value_pair(
        field: 'lead_status_id', value: inactive_status.id
      )

      # condition trigger join (default operator is OR)
      create :condition_trigger_join, trigger: trigger, condition: condition1
      create :condition_trigger_join, trigger: trigger, condition: condition2

      # actions to perform
      event_action = create(
        :action,
        trigger: trigger, klass: 'MarketingListLead', crud_action: destroy_crud
      )
      event_action.create_lookup_field_value_pair(
        field: 'lead_id', value: 'item.id', identifier: 'lookup'
      )

      # Dead test
      expect(lead.lead_status.name).to eq 'Active'
      expect(lead.marketing_lists.count).to eq 1

      # this will fire TriggerHandler.perform from the GlobalObserver
      lead.update_attribute(:lead_status, dead_status)

      expect(lead.lead_status.name).to eq 'Dead'
      expect(lead.marketing_lists.count).to eq 0

      # Inactive test
      lead.update_attribute(:lead_status, active_status)
      create :marketing_list_lead, lead: lead

      expect(lead.lead_status.name).to eq 'Active'
      expect(lead.marketing_lists.count).to eq 1

      # this will fire TriggerHandler.perform from the GlobalObserver
      lead.update_attribute(:lead_status, inactive_status)

      expect(lead.lead_status.name).to eq 'Inactive'
      expect(lead.marketing_lists.count).to eq 0
    end

    it "Lead's Agent changes, re-assign tasks and events to new agent" do
      lead = create :lead, agent: create(:agent)
      task = create :task, lead: lead, assignee: lead.agent
      task2 = create :task, lead: lead, assignee: lead.agent
      event = create :event, lead: lead, assignee: lead.agent
      new_agent = create :agent

      trigger = create :trigger, klass: 'Lead', crud_action: update_crud

      # actions to perform
      event_action = create(
        :action, trigger: trigger, klass: 'Event', crud_action: update_crud
      )
      event_action.create_lookup_field_value_pair(
        field: 'lead_id', value: 'item.id', identifier: 'lookup'
      )
      event_action.change_field_value_pairs.create(
        field: 'assignee_id', value: new_agent.id, identifier: 'change'
      )

      task_action = create(
        :action, trigger: trigger, klass: 'Task', crud_action: update_crud
      )
      task_action.create_lookup_field_value_pair(
        field: 'lead_id', value: 'item.id', identifier: 'lookup'
      )
      task_action.change_field_value_pairs.create(
        field: 'assignee_id', value: new_agent.id, identifier: 'change'
      )

      expect(lead.agent).to_not eq new_agent
      expect(task.assignee).to_not eq new_agent
      expect(task2.assignee).to_not eq new_agent
      expect(event.assignee).to_not eq new_agent

      # this will fire TriggerHandler.perform from the GlobalObserver
      lead.update_attribute(:agent, new_agent)

      event.reload
      task.reload
      task2.reload
      expect(event.assignee).to eq new_agent
      expect(task.assignee).to eq new_agent
      expect(task2.assignee).to eq new_agent
    end

    it "Lead's Agent changes, remove lead from old agents marketing lists " \
       "and add to new agent's marketing lists" do
      old_agent = create :agent
      new_agent = create :agent

      lead = create :lead, agent: old_agent
      marketing_list = create :marketing_list, agent: old_agent
      create(:marketing_list_lead, lead: lead, marketing_list: marketing_list)

      # won't change
      marketing_list2 = create :marketing_list, agent: old_agent
      create(
        :marketing_list_lead,
        lead: create(:lead),
        marketing_list: marketing_list2
      )

      trigger = create :trigger, klass: 'Lead', crud_action: update_crud

      marketing_list_action = create(
        :action,
        trigger: trigger, klass: 'MarketingList', crud_action: update_crud
      )

      marketing_list_action.create_lookup_field_value_pair(
        field: 'joins.marketing_list_leads.lead_id', value: 'item.id',
        identifier: 'lookup'
      )
      marketing_list_action.change_field_value_pairs.create(
        field: 'agent_id', value: new_agent.id,
        identifier: 'change'
      )

      expect(lead.agent).to_not eq new_agent
      expect(marketing_list.agent).to_not eq new_agent

      # this will fire TriggerHandler.perform from the GlobalObserver
      lead.update_attribute(:agent, new_agent)

      marketing_list.reload
      expect(marketing_list.agent).to eq new_agent
      expect(marketing_list2.agent).to eq old_agent # unchanged
    end
  end
end
