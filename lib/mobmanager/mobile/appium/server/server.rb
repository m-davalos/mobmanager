require_relative '../../../../mobmanager/mobile/os/os'

module Mobile
  module Appium
    module Server
      include OS

      def start_appium_server
        end_appium_server if node_running?
        puts 'Starting Appium server...'

        platform = ENV['PLATFORM']

        if platform == 'android'
          puts '-- Android Platform --'
          if ENV['ANDROID_PHONE'] == 'emulator'
            start_server
          else
            start_server ENV['DEVICE']
          end
        end

        if platform == 'ios'
          puts '-- IOS Platform --'
          if ENV['IOS_PHONE'] == 'simulator'
            start_server
          else
            start_server ENV['DEVICE']
          end
        end

        sleep 5
        puts "Appium is listening...\n\n"
      end

      def end_appium_server
        if node_running?
          puts 'Terminating Appium server...'
          if mac?
            termination = system 'pkill node'
          else
            termination = system 'TASKKILL /F /IM node.exe'
          end
          return print_response(termination)
        end
        puts 'No Appium server found.'
      end

      def node_running?
        if mac?
          return true if %x[ps aux | grep -i node | grep -v grep | wc -l].to_i > 0
        else
          return true if %x[tasklist /FI "IMAGENAME eq node.exe"].to_s.include? 'node'
        end
        false
      end

      private
      def print_response(success)
        return puts "Appium server terminated successfully." if success
        return puts "Appium server was not found." unless success
        warn '[PANIC]: Something went wrong while terminating the appium server.'
      end

      def start_server(id=nil, log_level='--log-level error')
        udid = "--udid #{id}" unless id.nil?
        command = "appium #{udid} #{log_level}"
        spawn command
      end
    end
  end
end
