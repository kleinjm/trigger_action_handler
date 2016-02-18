class GlobalObserver < ActiveRecord::Observer
  observe ActiveRecord::Base

  def after_commit(record)
    # if product.send(:transaction_include_action?, :destroy)

    # Rails 4 -   transaction_include_any_action?([:create])
    TriggerHandler.perform(record)
  end
end