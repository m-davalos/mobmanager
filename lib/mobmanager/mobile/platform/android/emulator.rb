require_relative '../../../../mobmanager/mobile/os/os'
require 'fileutils'

module Platform
  module Android
    module Emulator

      include OS

      ANDROID_EMULATOR ||= ENV['DEVICE']
      OFFLINE_CHECKS ||= 15

      def start_emulator
        spawn "emulator -avd #{ANDROID_EMULATOR} -no-audio"
      end

      # Wait until emulator is online
      def wait_for_emulator
        online = false
        iterations = 0
        while online == false && iterations < OFFLINE_CHECKS
          iterations += 1
          sleep 3
          puts 'Emulator is offline...'
          list_of_devices = %x[adb devices].to_s
          if list_of_devices.include? 'emulator'
            if list_of_devices.include? 'offline'
              online = false
            else
              puts "Emulator is online...\n\n"
              online = true
            end
          end
        end

        online
      end

      def retry_again
        puts 'Something went wrong while getting the AVD. Retrying now...'
        delete_locked_files
        terminate_emulator
        system 'adb kill-server'
        system 'adb start-server'
        start_emulator
        online = wait_for_emulator
        unless online
          fail 'Something went wrong while getting the AVD. Verify the selected AVD exists.'
        end
      end

      def terminate_emulator
        if emulator_running?
          puts 'Terminating Android emulator...'
          if mac?
            termination = system 'pkill -9 emulator'
          else
            termination = system 'TASKKILL /F /IM emulator-x86.exe'
            cleanup_after_emulator
          end
          print_termination_response(termination)
        end
      end

      def cleanup_after_emulator
        if mac?
          #remove /private/temp/android-<username>
          path = '/private/tmp'
          files = Dir["#{path}/**"]
          files.each do |file|
            if File.directory(file)
              FileUtils.remove_dir(file) if ((file.include? 'android-'))
            end
          end
        else
          # Delete temp files from AppData/Local/Temp/AndroidEmulator
          user_profile = %x[echo %USERPROFILE%].to_s.chomp!
          Dir.glob(user_profile.gsub("\\", '/')+ '//AppData//Local//Temp//AndroidEmulator//*.tmp').each { |f| File.delete(f) }
        end
      end

      def emulator_running?
        if mac?
          if %x[ps aux | grep -i emulator | grep -v grep | wc -l].to_i > 0
            return true
          end
        else
          if %x[tasklist /FI "IMAGENAME eq emulator-x86.exe"].to_s.include? 'emulator'
            return true
          end
        end
        false
      end

      private
      def print_termination_response(success)
        if success
          puts 'Android emulator terminated successfully.'
        elsif !success
          puts 'Android emulator was not found.'
        else
          warn '[PANIC]: Something went wrong while terminating the Android emulator.'
        end
      end

      def delete_locked_files
        # Delete lock files from ./.android/avd
        path = "#{Dir.home}/.android/avd"
        locks = Dir["#{path}/**/*.lock"]
        locks.each do |file|
          File.delete(file)
        end
      end
    end
  end
end