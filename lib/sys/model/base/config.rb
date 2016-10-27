module Sys::Model::Base::Config
  def states
    [['有効','enabled'],['無効','disabled']]
  end

  def enabled?
    return state == 'enabled'
  end

  def disabled?
    return state == 'disabled'
  end
end
