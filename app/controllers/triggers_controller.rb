class TriggersController < ApplicationController

  def new
    @trigger = Trigger.new
  end

  def create
    @trigger = Trigger.new(trigger_params)
    @trigger.save
    render "new"
  end

  private

  def trigger_params
    params.require(:trigger).permit(:model)
  end
end