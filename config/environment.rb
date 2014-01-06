# Load the rails application
require File.expand_path('../application', __FILE__)

Mime::Type.register 'application/json', :datatable

# Initialize the rails application
JabberCTS::Application.initialize!
