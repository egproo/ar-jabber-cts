require 'idn'

class String
  def nfkc_normalize
    IDN::Stringprep.nfkc_normalize(self).force_encoding(Encoding::UTF_8)
  end

  def nodeprep(fix_errors = true)
    profileprep('Nodeprep', fix_errors)
  end

  def resourceprep(fix_errors = true)
    profileprep('Resourceprep', fix_errors)
  end

  def nameprep(fix_errors = true)
    profileprep('Nameprep', fix_errors)
  end

  def profileprep(profile, fix_errors = true)
    str = self.nfkc_normalize
    IDN::Stringprep.with_profile(str, profile).force_encoding('utf-8')
  rescue IDN::Stringprep::StringprepError
    raise unless fix_errors

    str.each_char.map { |c, a|
      IDN::Stringprep.with_profile(c, profile) rescue nil
    }.join.force_encoding('utf-8')
  end
end
