FactoryGirl.define do
  factory :task do
    creator{ create :agent }
    assignee{ create :agent }
  end
end