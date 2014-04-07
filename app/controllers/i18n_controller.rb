class I18nController < ApplicationController
  skip_authorization_check

  def datatable
    send_file File.join(Rails.root, "config/locales/datatable.#{I18n.locale}.json")
  end
end
