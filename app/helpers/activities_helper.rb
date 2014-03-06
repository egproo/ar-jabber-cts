module ActivitiesHelper
  MODEL_ASSOCIATION_CLASSES = {
    'MoneyTransfer' => {
      sender_id: User,
      receiver_id: User,
    },
    'Contract' => {
      seller_id: User,
      buyer_id: User,
    }
  }

  def decorate(model, key, value)
    if value && model = MODEL_ASSOCIATION_CLASSES[model].try(:[], key.to_sym)
      value = model.find(value)
      link_to value, value
    else
      value.nil? ? "nil" : value
    end
  end
end
