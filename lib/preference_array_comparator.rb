class PreferenceArrayComparator
  def self.compare(a1, a2)
    if a1.size == a2.size
      a1.size.times do |index|
        v1, v2 = a1[index], a2[index]
        next if v1 == v2

        if (v1 == nil) != (v2 == nil)
          return v1 == nil ? 1 : -1
        else
          if v1 == false || v1 == true
            return v1 ? -1 : 1
          else
            return v1 <=> v2
          end
        end
      end
      0
    else
      a1.size <=> a2.size
    end
  end
end
