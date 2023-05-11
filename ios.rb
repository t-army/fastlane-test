prompt = TTY::Prompt.new

private_lane :ios_select_version do
  latest_testflight_build_number(api_key: lane_context[SharedValues::APP_STORE_CONNECT_API_KEY], app_identifier: APP_BUNDLE_ID)
  latest_version = lane_context[SharedValues::LATEST_TESTFLIGHT_VERSION]

  select_version(version: latest_version)
end

lane :ios_promote_testflight do
  #
end

lane :ios_ship_testflight do
  api_key = app_store_connect_api_key(
    key_id: APP_STORE_KEY_ID,
    issuer_id: APP_STORE_ISSUER_ID,
    key_content: APP_STORE_KEY_CONTENT_BASE64,
    is_key_content_base64: true,
    duration: 1200, # optional (maximum 1200)
    in_house: false, # optional but may be required if using match/sigh
  )

  # get latest build number from App Store
  # lane_context[SharedValues::LATEST_BUILD_NUMBER]
  app_store_build_number(
    initial_build_number: 1,
    live: false,
    version: get_version_number(xcodeproj: IOS_XCODEPROJ, target: IOS_TARGET),
    api_key: api_key,
    app_identifier: APP_BUNDLE_ID,
  )

  new_version = ios_select_version
  new_build_number = Time.new.strftime("%Y%m%d%H%M") # ex: 202301032335
  sentry_release_name = "#{new_version}+ios:#{new_build_number}"

  # update version
  set_properties_value(
    path: ENVIRONMENT_FILE,
    key: "APP_VERSION_IOS",
    value: new_version
  )

  # update build number
  set_properties_value(
    path: ENVIRONMENT_FILE,
    key: "APP_BUILD_NUMBER_IOS",
    value: new_build_number
  )

  build_ios_app(
    silent: true,
    workspace: IOS_XCWORKSPACE,
    scheme: IOS_SCHEME,
  )

  sh "mkdir -p ../dist/ios && touch ../dist/ios/bundle.ios.js ../dist/ios/bundle.ios.js.map && npx react-native bundle --platform=ios --dev=false --entry-file=index.js --bundle-output ../dist/ios/bundle.ios.js --sourcemap-output ../dist/ios/bundle.ios.js.map --assets-dest ../dist/ios"
  sentry_upload_artifacts(
    sentry_release_name: sentry_release_name,
    dist_version: new_build_number,
    platform: PLATFORMS::IOS
  )

  upload_to_testflight(api_key: api_key, skip_waiting_for_build_processing: true)

  # 🧽 Clear artifacts
  clean_build_artifacts
  sh "rm -rf \"#{lane_context[SharedValues::XCODEBUILD_ARCHIVE]}\""

  slack(
    **SLACK.TESTFLIGHT,
    pretext: "A new version uploaded via Fastlane!",
    payload: {
      "Environment": ENVIRONMENT.capitalize,
      "Version": new_version,
      "Build Number": new_build_number.to_s
    }
  )

  notification(title: APP_DISPLAY_NAME, subtitle: "Testflight", message: "Finished!!")
end

lane :ios_clear do |options|
  clearDerivedData = false
  clearPodsCache = false
  clearBuildArtifacts = false
  clearArchives = false

  completed = !!options[:force] || false

  while completed === false
    if prompt.yes?("Do you want to delete the Xcode Derived Data?")
      clearDerivedData = true
    end

    if prompt.yes?("Do you want to remove the cache for pods?")
      clearPodsCache = true
    end

    if prompt.yes?("Do you want to clean build artifacts?")
      clearBuildArtifacts = true
    end

    if prompt.yes?("Do you want to remove archives?")
      clearArchives = true
    end

    if prompt.yes?("Are you sure?")
      UI.success "Getting started.."
      completed = true
    else
      UI.message "Here we again..."
    end
  end

  if clearDerivedData || !!options[:force]
    clear_derived_data
  end

  if clearPodsCache || !!options[:force]
    clean_cocoapods_cache
  end

  if clearBuildArtifacts || !!options[:force]
    clean_build_artifacts
  end

  if clearArchives || !!options[:force]
    sh(command: "rm -vfr ~/Library/Developer/Xcode/Archives/*")
  end
end