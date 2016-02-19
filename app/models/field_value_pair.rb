class FieldValuePair < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  def self.hashify(pairs, item)
    pairs.each_with_object({}) do |pair, hash|
      hash[pair.field.parameterize.underscore.to_sym] = TriggerHandler.evaluate_value(pair.value, item)
    end
  end
end