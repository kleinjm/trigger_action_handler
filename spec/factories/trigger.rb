FactoryGirl.define do
  factory :trigger do
    crud_action { create :crud_action }

    factory :deal_trigger do
      klass "Deal"
    end
  end
end