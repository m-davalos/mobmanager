require 'yaml'
require_relative '../../../../mobmanager/mobile/os/os'

module Platform
  module IOS
    module Simulator

      include OS

      def start_simulator
        caps = YAML.load_file(Dir.pwd + '/features/support/settings/ios.yml')
        puts 'Building ios app with xcodebuild tool...'
        # system "xcodebuild -workspace #{$workspace_path} -scheme \"#{$app.gsub('.app', '')}\" -configuration Debug -sdk \"#{$iphone_simulator}\" -derivedDataPath \"~/\""
        # if ENV['TARGET'] == 'sauce'
        #   puts 'Connecting to sauce server...'
        #   system "curl https://#{$sauce_user}:#{$sauce_key}@saucelabs.com/rest/v1/users/#{$sauce_user}"
        #   puts 'Zipping iOS app'
        #   system "zip -r #{$zipped_path} #{$app_path}/"
        #   puts 'Sending zipped app to sauce storage'
        #   system 'curl -u '+"#{$sauce_user}:#{$sauce_key}"+' -X POST "https://saucelabs.com/rest/v1/storage/'+$sauce_user+'+/'+$app+'.zip?overwrite=true" -H "Content-Type: application/octet-stream" --data-binary @'+$zipped_path
        # end
        system "xcodebuild -workspace #{caps[:workspace_path]} -scheme \"#{caps[:app].gsub('.app', '')}\" -configuration Debug -sdk \"#{caps[:sim_sdk]}\" -derivedDataPath \"~/\""
        if ENV['TARGET'] == 'sauce'
          puts 'Connecting to sauce server...'
          system "curl https://#{$sauce_user}:#{$sauce_key}@saucelabs.com/rest/v1/users/#{$sauce_user}"
          puts 'Zipping iOS app'
          system "zip -r #{$zipped_path} #{$app_path}/"
          puts 'Sending zipped app to sauce storage'
          system 'curl -u '+"#{$sauce_user}:#{$sauce_key}"+' -X POST "https://saucelabs.com/rest/v1/storage/'+$sauce_user+'+/'+$app+'.zip?overwrite=true" -H "Content-Type: application/octet-stream" --data-binary @'+$zipped_path
        end
      end

      def terminate_simulator
        spawn 'killall "iOS Simulator"'
        spawn 'killall -9 instruments'
      end

      def close_and_clean_simulator
        terminate_simulator
        remove_sim_temp_files
      end

      def remove_sim_temp_files
        if mac?
          #remove ios related files from /private/temp/
          path = '/private/tmp'
          files = Dir["#{path}/**"]
          files.each do |file|
            if File.directory?(file)
              FileUtils.remove_dir(file) if ((file.include? 'com.apple.') || (file.include? 'appium-instruments'))
            end
          end
        else
          # TODO - research in Windows OS
        end
      end
    end
  end
end