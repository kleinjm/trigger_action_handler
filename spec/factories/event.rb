FactoryGirl.define do
  factory :event do
    creator{ create :agent }
    assignee{ create :agent }
  end
end