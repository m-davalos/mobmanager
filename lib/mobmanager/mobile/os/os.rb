module OS
  def mac?
    begin
      os = %x[sw_vers -productName]
    rescue Exception
      os = nil
    end
    if os.nil?
      return false if %x[ver].to_s.downcase.include? 'windows'
    elsif os
      return true if %[sw_vers -productName].to_s.downcase.include? 'mac'
    else
      fail '[PANIC:] Failed to determine OS.'
      return false
    end
    true
  end
end
