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

  STRIPPED_FIELDS = %w(adhoc_data encrypted_password)

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
      if STRIPPED_FIELDS.include?(key)
        "#{key}: has been changed"
      else
        "#{key}: #{decorate(model, key, value[0])} => #{decorate(model, key, value[1])}"
      end
    elsif (value && value != "") && (STRIPPED_FIELDS.include?(key))
      "#{key}: has been set"
    elsif STRIPPED_FIELDS.include?(key)
      "#{key}: has been cleared"
    else
      "#{key}: #{decorate(model, key, value)}"
    end
  end
end
