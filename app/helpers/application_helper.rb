module ApplicationHelper
  RESOURCE_ACTIONS_TITLE_MAP = {
    'new' => 'New %s',
    'create' => 'New %s',
    'edit' => 'Edit %s',
    'update' => 'Edit %s',
    'show' => '%s info',
  }

  def resources_page_title
    subject_name = params[:controller].titleize
    if singleton_title_template = RESOURCE_ACTIONS_TITLE_MAP[params[:action]]
      singleton_title_template % subject_name.singularize
    else
      subject_name
    end
  end
end
