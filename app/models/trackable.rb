module Trackable
  def self.included(model)
    model.send(:include, PublicActivity::Model)
    model.tracked owner: proc { |controller, model| controller.try(:current_user) }
    super
  end
end
