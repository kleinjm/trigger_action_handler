seeds = {
  "lead_priorities" => ['Highest', 'High', 'Normal', 'Low', 'Lowest'],
  "lead_statuses" => ['Incubating', 'Client', 'Closed', 'Dead', 'UAG', 'New', 'Inactive'],
  "lead_types" => ['Buying', 'Selling', 'Renting', 'Other', 'Just Looking', 'Commercial', 'Buying & Selling', 'Exception', 'Agent/Broker'],
  "phone_types" => ['Home', 'Cell', 'Work', 'Fax'],
  "task_priorities" => ['Normal', 'High', 'Low'],
  "task_statuses" => ['Open', 'In Progress', 'Completed', 'On Hold', 'Rejected', 'Canceled']
  "crud_actions" => ['create', 'update', 'delete']
}
seeds.each do |klass_name, values|
  klass = klass_name.classify.constantize
  values.each do |val|
    klass.find_or_create_by(name: val)
  end
end
deal_stages = [
  {:name => 'Offer Pending', :open => true, :closed => false, :dead => false},
  {:name => 'Offer Accepted', :open => true, :closed => false, :dead => false},
  {:name => 'Under Contract', :open => true, :closed => false, :dead => false},
  {:name => 'Closed', :open => false, :closed => true, :dead => false},
  {:name => 'Dead', :open => false, :closed => false, :dead => true}
]
deal_stages.each do |stage|
  deal_stage = DealStage.find_or_create_by(name: stage[:name])
  deal_stage.open = stage[:open]
  deal_stage.closed = stage[:closed]
  deal_stage.dead = stage[:dead]
  deal_stage.save
end
