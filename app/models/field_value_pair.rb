class FieldValuePair < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  validates_presence_of :owner, :field, :value

  # return a params hash of the given pairs
  def self.to_hash(pairs, item)
    pairs.each_with_object({}) do |pair, hash|
      hash[pair.field.parameterize.underscore.to_sym] =
        TriggerHandler.evaluate_value(pair.value, item)
    end
  end
end
