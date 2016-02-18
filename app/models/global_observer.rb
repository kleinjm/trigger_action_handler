class GlobalObserver < ActiveRecord::Observer
  observe ActiveRecord::Base

  def after_commit(record)
    TriggerHandler.perform(record, transaction_type(record))
  end

  private

  # return the transaction type that occured
  # NOTE: a bit funkey because transaction_include_any_action? is a 
  # private method on ActiveRecord::Transactions and takes an array
  def transaction_type(record)
    return "create" if record.send(:transaction_include_any_action?, [:create])
    return "update" if record.send(:transaction_include_any_action?, [:update])
    return "destroy" if record.send(:transaction_include_any_action?, [:destroy])
  end
end