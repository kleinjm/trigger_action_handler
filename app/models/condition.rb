class Condition < ActiveRecord::Base

  has_many :condition_trigger_joins
  has_many :triggers, through: :condition_trigger_joins

  has_one :field_value_pair, as: :owner

end