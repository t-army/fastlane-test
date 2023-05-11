require 'dotenv'
require 'tty-prompt'

opt_out_usage
skip_docs
prompt = TTY::Prompt.new

import("./android.rb")
import("./ios.rb")
import("./codepush.rb")
import("./sentry.rb")
import("./misc.rb")
import("./enums.rb")

private_lane :cleanup do
  sh "rm -rf ../dSYMs ../dist ../*.ipa ../*.dSYM.zip"
end

private_lane :init_variables do
  ENVIRONMENT = ENV["ENVIRONMENT"]
  ENVIRONMENT_FILE = ".env.#{ENVIRONMENT}"

  env_path = "../.env"
  File.delete(env_path) if File.exist?(env_path)

  ANDROID_FLAVOR = ENV["ANDROID_FLAVOR"]

  APP_DISPLAY_NAME = ENV["APP_DISPLAY_NAME"]
  APP_BUNDLE_ID = ENV["APP_BUNDLE_ID"]
  APP_PACKAGE_NAME = ENV["APP_PACKAGE_NAME"]

  CODEPUSH_ANDROID_PROJECT_NAME = ENV["CODEPUSH_ANDROID_PROJECT_NAME"]
  CODEPUSH_IOS_PROJECT_NAME = ENV["CODEPUSH_IOS_PROJECT_NAME"]
  CODEPUSH_CHANNEL_NAME = ENV["CODEPUSH_CHANNEL_NAME"]
  CODEPUSH_IOS_KEY = ENV["CODEPUSH_IOS"]
  CODEPUSH_ANDROID_KEY = ENV["CODEPUSH_ANDROID"]

  CODEPUSH_PARAMS = {
    api_token: ENV["CODEPUSH_API_TOKEN"],
    owner_name: ENV["CODEPUSH_ORGANIZATION_NAME"],
  }

  IOS_XCWORKSPACE = ENV["IOS_XCWORKSPACE"]
  IOS_XCODEPROJ = ENV["IOS_XCODEPROJ"]
  IOS_SCHEME = ENV["IOS_SCHEME"]
  IOS_TARGET = ENV["IOS_TARGET"]
  IOS_BUILD_NAME = ENV["IOS_BUILD_NAME"]

  APP_STORE_KEY_ID = ENV["APP_STORE_KEY_ID"]
  APP_STORE_ISSUER_ID = ENV["APP_STORE_ISSUER_ID"]
  APP_STORE_KEY_CONTENT_BASE64 = ENV["APP_STORE_KEY_CONTENT_BASE64"]

  SLACK_PARAMS = {
    slack_url: ENV["SLACK_WEBHOOK_URL"],
    channel: "#mobile-app-updates",
    success: true,
    default_payloads: [],
  }

  SLACK = {
    TESTFLIGHT: {
      **SLACK_PARAMS,
      username: "Testflight",
      icon_url: "https://firebasestorage.googleapis.com/v0/b/popile-firebase-staging.appspot.com/o/slack%2Ftestflight.png?alt=media&token=9d244963-8f7c-4038-ac0d-17fe03253b78",
    },
    GOOGLE_PLAY: {
      **SLACK_PARAMS,
      username: "Google Play",
      icon_url: "https://firebasestorage.googleapis.com/v0/b/popile-firebase-staging.appspot.com/o/slack%2Fgoogle-play.png?alt=media&token=fa0d65c5-7cd7-4e53-a9e8-2b62bb9551f0",
    },
    CODEPUSH: {
      **SLACK_PARAMS,
      username: "CodePush",
      icon_url: "https://firebasestorage.googleapis.com/v0/b/popile-firebase-staging.appspot.com/o/slack%2Fcodepush.png?alt=media&token=05c9bc42-ba7b-4932-8449-04faf1207e3b",
    }
  }

  PLAY_STORE_PARAMS = {
    package_name: ENV["APP_PACKAGE_NAME"],
    json_key_data: ENV["PLAY_STORE_CONFIG_JSON"]
  }

  SENTRY_AUTH_PARAMS = {
    auth_token: ENV["SENTRY_AUTH_TOKEN"],
    org_slug: ENV["SENTRY_ORG_SLUG"],
    project_slug: ENV["SENTRY_PROJECT_SLUG"],
    sentry_cli_path: "node_modules/@sentry/cli/bin/sentry-cli"
  }
end

private_lane :select_environment do
  selection = prompt.select("Which environment do you want to use?", [
    {value: ENVIRONMENTS::STAGING, name: "Staging"},
    {value: ENVIRONMENTS::PRODUCTION, name: "Production"},
  ])

  case selection
    when ENVIRONMENTS::STAGING
      Dotenv.load('../.env.staging', '../.env.secrets')
      init_variables
    when ENVIRONMENTS::PRODUCTION
      Dotenv.load('../.env.production', '../.env.secrets')
      init_variables
  end

  selection
end

private_lane :select_platform do
  selection = prompt.select("Which platform do you want to use?", [
    {value: PLATFORMS::ANDROID, name: "Android"},
    {value: PLATFORMS::IOS, name: "iOS"},
  ])

  selection
end

lane :interactive do
  choices = [
    {value: MENU::BUILD_ANDROID_EMULATOR, name: "🤖 - Build -> Android Emulator"},
    {value: MENU::BUILD_IOS_SIMULATOR, name: "📱 - Build -> iOS Simulator"},
    {value: MENU::BUILD_FOR_APP_STORE, name: "🐸 - Build & Deploy -> App Store (iOS)"},
    {value: MENU::BUILD_FOR_GOOGLE_PLAY, name: "🐵 - Build & Deploy -> Google Play (Android)"},
    {value: MENU::PROMOTE_ANDROID_INTERNAL, name: "⭐️ - Promote Android (Internal -> Production)"},
    {value: MENU::PROMOTE_IOS_TESTFLIGHT, name: "🌟 - Promote iOS (Testflight -> Production)", disabled: "(wip)"},
    {value: MENU::CODEPUSH_UPDATE, name: "📦 - OTA (over-the-air) Update (CodePush)"},
    {value: MENU::DOCTOR, name: "🥼 - Doctor"},
    {value: MENU::CLEAR_CACHE, name: "🧽 - Flip Table (┛✧Д✧))┛彡┻━┻ (Clearing Cache)"},
  ]
  selection = prompt.select("Select a task:", choices, cycle: true, per_page: 9, filter: true)

  case selection
    when MENU::BUILD_ANDROID_EMULATOR
      case select_environment
        when ENVIRONMENTS::STAGING
          sh "yarn run android:staging:debug"
        when ENVIRONMENTS::PRODUCTION
          sh "yarn run android:production:debug"
      end
    when MENU::BUILD_IOS_SIMULATOR
      case select_environment
        when ENVIRONMENTS::STAGING
          sh "yarn run ios:staging:debug"
        when ENVIRONMENTS::PRODUCTION
          sh "yarn run ios:production:debug"
      end
    when MENU::BUILD_FOR_APP_STORE
      begin
        select_environment
        ios_ship_testflight
        cleanup
      rescue
        cleanup
      end
    when MENU::BUILD_FOR_GOOGLE_PLAY
      begin
        select_environment
        android_ship_internal
        cleanup
      rescue
        cleanup
      end
    when MENU::PROMOTE_ANDROID_INTERNAL
      select_environment
      android_promote_internal
    when MENU::PROMOTE_IOS_TESTFLIGHT
      select_environment
      ios_promote_testflight
    when MENU::CODEPUSH_UPDATE
      begin
        select_environment

        case select_platform
          when PLATFORMS::ANDROID
            codepush_ship_android
          when PLATFORMS::IOS
            codepush_ship_ios
        end

        cleanup
      rescue
        cleanup
      end
    when MENU::DOCTOR
      sh "yarn run doctor"
    when MENU::CLEAR_CACHE
      selection = prompt.select("Which option do you want to select?", [
        {value: CLEAR_OPTIONS::ANDROID, name: "Android"},
        {value: CLEAR_OPTIONS::IOS, name: "iOS"},
        {value: CLEAR_OPTIONS::ALL, name: "All Caches"},
        {value: CLEAR_OPTIONS::ALL_EXTREME, name: "All Caches Extreme (included global yarn and pods cache)"},
      ])

      case selection
        when CLEAR_OPTIONS::ANDROID
          android_clear
        when CLEAR_OPTIONS::IOS
          ios_clear
        when CLEAR_OPTIONS::ALL
          android_clear
          ios_clear(force: true)
          flip_table
        when CLEAR_OPTIONS::ALL_EXTREME
          android_clear
          ios_clear(force: true)
          sh "yarn cache clean"
          sh "bundle exec pod cache clean --all"
          flip_table
      end
  end
end
