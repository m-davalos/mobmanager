require_relative '../../../../mobmanager/mobile/os/os'

module Platform
  module Android
    module Device

      include OS

      ANDROID_DEVICE ||= ENV['DEVICE']

      def start_android_device
        puts "Setting android device #{ANDROID_DEVICE}"
        system 'adb start-server'
        wait_for_android_device
      end

      def wait_for_android_device
        max_wait = 5
        counter = 0

        found = false
        while !found && counter <= max_wait
          devices = %x[adb devices]
          list = list_of_devices(devices)
          begin
            found = is_partial_string_in_array?(ANDROID_DEVICE, list)
          rescue Exception => e
            found = false
          end
          if found
            return puts "Android device #{ANDROID_DEVICE} found."
          end
          counter += 1
        end
      end

      def terminate_android_device
        system 'adb kill-server'
      end
    end
  end
end

#TODO - move to a helper module maybe adb?
def list_of_devices(text)
  devices = []
  lines = text.split("\n")

  lines.each do |ele|
    if ele.include?("\t")
      devices << ele.split("\t")
    else
      devices << ele
    end
  end

  devices.flatten!
end

def is_partial_string_in_array?(part_of_string, in_array)
  in_array.each do |element|
    return true if part_of_string.include? element
    false
  end
end