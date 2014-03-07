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

  def adhoc_data(model, key, value)
    if value.is_a?(Array)
      if key == 'encrypted_password' || key == 'adhoc_data'
        "#{key}: has been changed"
      else
        "#{key}: #{decorate(model, key, value[0])} => #{decorate(model, key, value[1])}"
      end
    elsif (value && value != "") && (key == 'encrypted_password' || key == 'adhoc_data')
      "#{key}: has been set"
    elsif key == 'encrypted_password' || key == 'adhoc_data'
      "#{key}: has been cleared"
    else
      "#{key}: #{decorate(model, key, value)}"
    end
  end
end
