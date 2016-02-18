FactoryGirl.define do
  factory :action do
    trigger{ create :trigger }
    crud_action{ create :crud_action }
    klass "Deal"
  end
end