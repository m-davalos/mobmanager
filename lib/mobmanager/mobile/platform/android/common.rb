require_relative '../../../../mobmanager/mobile/platform/android/device'
require_relative '../../../../mobmanager/mobile/platform/android/emulator'

module Platform
  module Android
    module Common

      include Platform::Android::Device
      include Platform::Android::Emulator

      def prepare_android_phone
        if ENV['ANDROID_PHONE'] == 'emulator'
          terminate_emulator
          start_emulator
          online = wait_for_emulator
          retry_again unless online
        else
          start_android_device
        end
      end

      def back_button
        %x[adb shell input keyevent KEYCODE_BACK]
      end

    end
  end
end