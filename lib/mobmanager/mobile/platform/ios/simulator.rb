require 'yaml'
require_relative '../../../../mobmanager/mobile/os/os'

module Platform
  module IOS
    module Simulator

      include OS

      def start_simulator(settings = nil)
        caps = settings unless settings.nil?
        caps = YAML.load_file(Dir.pwd + '/features/support/settings/ios.yml') if settings.nil?

        unless caps[:workspace_path].nil?
          build_ios_app(caps)
        end

        if ENV['TARGET'] == 'sauce'
          setup_for_sauce(caps)
        end
      end

      def build_ios_app(settings)
        puts 'Building ios app with xcodebuild tool...'
        puts 'MobTest: Building ios app with xcodebuild tool...'
        #TODO - Add to PATH?
        puts "ENV['IOS_DERIVED_DATA_PATH'] #{ENV['IOS_DERIVED_DATA_PATH']}"
        fail("MobTest: Failed to determine app_path. Please check your ios.yml settings") if settings[:app_path].nil?
        app = settings[:app_path].split('/').select{|element| element.include?'.app'}.first
        system "xcodebuild -workspace #{settings[:workspace_path]} -scheme \"#{app.gsub('.app', '')}\" -configuration Debug -sdk \"#{settings['sim_sdk']}\" -derivedDataPath \"~/\""
      end

      def setup_for_sauce(settings)
        sauce_user = %x[echo $SAUCE_USER].strip
        sauce_key = %x[echo $SAUCE_KEY].strip
        app_path = settings[:app_path]
        zipped_app_path = app_path.gsub('.app','.zip')
        app = app_path.split('/').select{|item| item.include?('.app')}.first.gsub('.app','')
        puts 'MobTest: Connecting to sauce server...'
        system "curl https://#{sauce_user}:#{sauce_key}@saucelabs.com/rest/v1/users/#{sauce_user}"
        puts 'MobTest: Zipping iOS app'
        system "zip -r #{zipped_app_path} #{app_path}/"
        zipped_app_path = zipped_app_path.gsub('~',Dir.home)
        puts 'MobTest: Sending zipped app to sauce storage'
        system 'curl -u '+"#{sauce_user}:#{sauce_key}"+' -X POST "https://saucelabs.com/rest/v1/storage/'+sauce_user+'/'+app+'.zip?overwrite=true" -H "Content-Type: application/octet-stream" --data-binary @'+zipped_app_path
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