FactoryGirl.define do
  factory :trigger do
    crud_action { create :crud_action }
    klass "Deal"
  end
end