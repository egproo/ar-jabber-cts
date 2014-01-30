require 'idn'

class String
  def nfkc_normalize
    IDN::Stringprep.nfkc_normalize(self)
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
    str = IDN::Stringprep.nfkc_normalize(self)
    IDN::Stringprep.with_profile(str, profile)
  rescue IDN::Stringprep::StringprepError
    raise unless fix_errors

    str.each_char.map { |c, a|
      IDN::Stringprep.with_profile(c, profile) rescue nil
    }.join
  end
end
