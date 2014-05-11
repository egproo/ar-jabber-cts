require 'idn'

class JID
  attr_accessor :node, :name, :resource

  def initialize(str)
    node, name_resource = str.split('@', 2)
    if name_resource
      name, resource = name_resource.split('/', 2)
    else
      # can't have "name/resource" form w/o node
      node, name, resource = nil, node, nil
    end

    @node = self.class.profileprep(node, 'Nodeprep') if node
    @name = self.class.profileprep(name, 'Nameprep') if name
    @resource = self.class.profileprep(resource, 'Resourceprep') if resource
  end

  def to_s
    str = name
    str = "#{node}@#{str}" if node
    str << "/#{resource}" if resource
    str
  end

  private
  def self.nfkc_normalize(str)
    IDN::Stringprep.nfkc_normalize(str).force_encoding(Encoding::UTF_8)
  end

  def self.profileprep(str, profile, fix_errors = true)
    str = nfkc_normalize(str)
    IDN::Stringprep.with_profile(str, profile).force_encoding('utf-8')
  rescue IDN::Stringprep::StringprepError
    raise unless fix_errors

    str.each_char.map { |c, a|
      IDN::Stringprep.with_profile(c, profile) rescue nil
    }.join.force_encoding('utf-8')
  end
end
