require 'yaml'
require_relative '../../../../mobmanager/mobile/os/os'

module Platform
  module IOS
    module Simulator

      include OS

      def start_simulator
        # caps = YAML.load_file(Dir.pwd + '/features/support/settings/ios.yml')
        $app = $app_path.split('/').select{|element| element.include?'.app'}.first
        unless $workspace_path.nil?
          puts 'Building ios app with xcodebuild tool...'
          puts "xcodebuild -workspace #{$workspace_path} -scheme \"#{$app.gsub('.app', '')}\" -configuration Debug -sdk \"#{$sim_sdk}\" -derivedDataPath \"~/\""
          system "xcodebuild -workspace #{$workspace_path} -scheme \"#{$app.gsub('.app', '')}\" -configuration Debug -sdk \"#{$sim_sdk}\" -derivedDataPath \"~/\""
        end
        # if ENV['TARGET'] == 'sauce'
        #   puts 'Connecting to sauce server...'
        #   system "curl https://#{$sauce_user}:#{$sauce_key}@saucelabs.com/rest/v1/users/#{$sauce_user}"
        #   puts 'Zipping iOS app'
        #   system "zip -r #{$zipped_path} #{$app_path}/"
        #   puts 'Sending zipped app to sauce storage'
        #   system 'curl -u '+"#{$sauce_user}:#{$sauce_key}"+' -X POST "https://saucelabs.com/rest/v1/storage/'+$sauce_user+'+/'+$app+'.zip?overwrite=true" -H "Content-Type: application/octet-stream" --data-binary @'+$zipped_path
        # end
        # system "xcodebuild -workspace #{caps[:workspace_path]} -scheme \"#{caps[:app].gsub('.app', '')}\" -configuration Debug -sdk \"#{caps[:sim_sdk]}\" -derivedDataPath \"~/\""
        if ENV['TARGET'] == 'sauce'
          zipped_app_path = $app_path.gsub('.app','.zip')
          puts 'MobTest: Connecting to sauce server...'
          system "curl https://#{$sauce_user}:#{$sauce_key}@saucelabs.com/rest/v1/users/#{$sauce_user}"
          puts 'MobTest: Zipping iOS app'
          system "zip -r #{zipped_app_path} #{$app_path}/"
          puts 'MobTest: Sending zipped app to sauce storage'
          system 'curl -u '+"#{$sauce_user}:#{$sauce_key}"+' -X POST "https://saucelabs.com/rest/v1/storage/'+$sauce_user+'+/'+$app+'.zip?overwrite=true" -H "Content-Type: application/octet-stream" --data-binary @'+zipped_app_path
        end
      end

      def build_ios_app(settings)
        puts 'MobTest: Building ios app with xcodebuild tool...'
        system "xcodebuild -workspace #{settings[:workspace_path]} -scheme \"#{settings[:app].gsub('.app', '')}\" -configuration Debug -sdk \"#{settings[:sim_sdk]}\" -derivedDataPath \"~/\""
      end

      def setup_for_sauce(settings)
        sauce_user = settings[:sauce_user]
        sauce_key = settings[:sauce_key]
        zipped_path = settings[:app_path].gsub('.app','.zip')
        app_path = settings[:app_path]
        app = app_path.split('/').select{|item| item.include?('.app')}.first

        puts 'Connecting to sauce server...'
        system "curl https://#{sauce_user}:#{sauce_key}@saucelabs.com/rest/v1/users/#{sauce_user}"
        puts 'Zipping iOS app'
        system "zip -r #{zipped_path} #{app_path}/"
        puts 'Sending zipped app to sauce storage'
        system 'curl -u '+"#{sauce_user}:#{sauce_key}"+' -X POST "https://saucelabs.com/rest/v1/storage/'+sauce_user+'+/'+app+'.zip?overwrite=true" -H "Content-Type: application/octet-stream" --data-binary @'+zipped_path
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