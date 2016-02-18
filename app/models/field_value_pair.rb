class FieldValuePair < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  def self.hashify(pairs)
    pairs.each_with_object({}) do |pair, hash|
      hash[pair.field.parameterize.underscore.to_sym] = pair.value
    end
  end
end