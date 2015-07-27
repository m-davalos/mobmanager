module OS
  def mac?
    os = %x[sw_vers -productName]
    if os.nil? || os.empty?
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
