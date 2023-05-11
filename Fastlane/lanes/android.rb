prompt = TTY::Prompt.new

private_lane :android_select_version do |options|
  versions = google_play_track_release_names(
    **PLAY_STORE_PARAMS,
    track: options[:track]
  )

  if versions.empty?
    UI.user_error!("Whoops, current version not found!")
  end

  select_version(version: versions[0])
end

lane :android_promote_internal do
  version_codes = google_play_track_version_codes(
    **PLAY_STORE_PARAMS,
    track: "internal",
  ).first(20)

  UI.header "Last 20 Android builds"

  selected_version_code = prompt.select("Which build would you like to release?: ", version_codes)

  if prompt.yes?("Are you sure you would like to release '#{selected_version_code}'?")
    UI.success "Continuing the release!"
  else
    UI.user_error!("Stopping the train!")
  end

  upload_to_play_store(
    **PLAY_STORE_PARAMS,
    track: "internal",
    version_code: selected_version_code,
    track_promote_to: 'production',
    rollout: '0.1',
    skip_upload_metadata: true,
    skip_upload_changelogs: true,
    skip_upload_images: true,
    skip_upload_screenshots: true,
  )
end

lane :android_ship_internal do
  new_version = android_select_version(track: "internal")
  new_build_number = Time.now.to_i / 10 # ex: 167293091

  # update version
  set_properties_value(
    path: ENVIRONMENT_FILE,
    key: "APP_VERSION_ANDROID",
    value: new_version
  )

  set_properties_value(
    path: ENVIRONMENT_FILE,
    key: "APP_BUILD_NUMBER_ANDROID",
    value: new_build_number
  )

  gradle(task: "bundle", flavor: ANDROID_FLAVOR, build_type: "Release", project_dir: "android")

  sh "mkdir -p ../dist/android && touch ../dist/android/bundle.android.js ../dist/android/bundle.android.js.map && npx react-native bundle --platform=android --dev=false --entry-file=index.js --bundle-output ../dist/android/bundle.android.js --sourcemap-output ../dist/android/bundle.android.js.map --assets-dest ../dist/android"

  sentry_upload_artifacts(
    sentry_release_name: "#{new_version}+android:#{new_build_number}",
    dist_version: new_build_number,
    platform: PLATFORMS::ANDROID
  )

  upload_to_play_store(
    **PLAY_STORE_PARAMS,
    track: "internal",
    aab: "android/app/build/outputs/bundle/#{ENVIRONMENT}Release/app-#{ENVIRONMENT}-release.aab",
    skip_upload_apk: true,
    # Only releases with status draft may be created on draft app
    # Staging app is a draft app therefore we can't create ready to use relases on staging
    release_status: ENVIRONMENT === "staging" ? "draft" : "completed"
  )

  slack(
    **SLACK.GOOGLE_PLAY,
    pretext: "A new version uploaded to *Internal App Sharing Channel* via Fastlane!",
    payload: {
      "Environment": ENVIRONMENT.capitalize,
      "Version": new_version,
      "Build Number": new_build_number.to_s
    }
  )

  notification(title: APP_DISPLAY_NAME, subtitle: "Google Play - Internal App Sharing", message: "Finished!!")
end

lane :android_clear do
  gradle(task: "clean", project_dir: "android")
end