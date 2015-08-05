require_relative '../../../../mobmanager/mobile/platform/ios/device'
require_relative '../../../../mobmanager/mobile/platform/ios/simulator'

module Platform
  module IOS
    module Common
      include Platform::IOS::Device
      include Platform::IOS::Simulator

      def prepare_ios_phone(settings = nil)
        if ENV['IOS_PHONE'] == 'simulator'
          terminate_simulator
          start_simulator(settings)
        else
          start_ios_device
        end
      end

    end
  end
end