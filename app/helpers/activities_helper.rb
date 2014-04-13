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
    # f.e. MODEL_ASSOCIATION_CLASSES['Contract'][:buyer_id]
    if value && model = MODEL_ASSOCIATION_CLASSES[model].try(:[], key.to_sym)
      # If user with this ID (value) exists
      if value = model.find_by_id(value)
        link_to value, value
      else
        'not found'
      end
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
    elsif value.present? && (STRIPPED_FIELDS.include?(key))
      "#{key}: has been set"
    elsif STRIPPED_FIELDS.include?(key)
      "#{key}: has been cleared"
    else
      "#{key}: #{decorate(model, key, value)}"
    end
  end
end
