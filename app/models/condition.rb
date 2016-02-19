class Condition < ActiveRecord::Base

  has_many :condition_trigger_joins
  has_many :triggers, through: :condition_trigger_joins

  has_one :field_value_pair, as: :owner, dependent: :destroy

  # basic ruby comparison operators
  OPERATORS = ["==","!=",">","<",">=","<=","<=>","===","eql?","equal?"]

  validates_presence_of :operator
  validates :operator, inclusion: { in: OPERATORS, message: "Invalid operator" }
end