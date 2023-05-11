prompt = TTY::Prompt.new

private_lane :codepush_select_target_version do |options|
  current_version = options[:current_version]
  current_major = [current_version.split(".").first, "x", "x"].join(".")
  current_minor = current_version.split(".").slice(0, 2).push("x").join(".")

  target_version_label = prompt.select("What version do you want to target?", [
    "All users",
    "Most recent major (#{current_major})",
    "Most recent minor (#{current_minor})",
    "Current version (#{current_version})",
  ])

  next "\"*\"" if target_version_label.match(/All/)
  next current_major if target_version_label.match(/major/)
  next current_minor if target_version_label.match(/minor/)

  current_version
end

private_lane :codepush_ship do |options|
  manditory = prompt.yes?("Do you make this release manditory?")

  if prompt.yes?("Do you want to add release note?")
    release_note = prompt(text: "Release Notes: ", multi_line_end_keyword: "END")
  else
    release_note = ""
  end

  target_version = codepush_select_target_version(current_version: options[:current_version])

  if prompt.yes?("Going to CodePush #{target_version} to #{CODEPUSH_CHANNEL_NAME}. Feeling lucky?")
    appcenter_codepush_release_react(
      **CODEPUSH_PARAMS,
      app_name: options[:project_name],
      deployment: CODEPUSH_CHANNEL_NAME,
      target_version: target_version,
      mandatory: manditory,
      description: release_note,
      output_dir: "./dist",
    )
  else
    UI.error "Not going to push"
  end
end

private_lane :codepush_get_update_info do |options|
  meta_str = sh("curl --silent --location --request GET 'https://api.appcenter.ms/v0.1/public/codepush/update_check?deployment_key=#{options[:deployment_key]}&app_version=#{options[:app_version]}'")
  meta = JSON.parse(meta_str)
  label = meta["update_info"]["label"]
  target_binary_range = meta["update_info"]["target_binary_range"]
  is_mandatory = meta["update_info"]["is_mandatory"]
  download_url = meta["update_info"]["download_url"]

  [target_binary_range, label, is_mandatory, download_url]
end

lane :codepush_ship_android do
  versions = google_play_track_release_names(
    **PLAY_STORE_PARAMS,
    track: ENVIRONMENT === "staging" ? "internal" : "production"
  )

  if versions.empty?
    UI.user_error!("Whoops, current version not found!")
  else
    current_version = versions[0]

    pattern = /\d\.\d\.\d/

    if current_version.match?(pattern)
      current_version = current_version.match(pattern)[0]
    else
      UI.user_error!("Whoops, current version not parsable!")
    end
  end

  codepush_ship(
    current_version: current_version,
    project_name: CODEPUSH_ANDROID_PROJECT_NAME
  )

  target_binary_range, label, is_mandatory, download_url = codepush_get_update_info(deployment_key: CODEPUSH_ANDROID_KEY, app_version: current_version)

  sentry_upload_artifacts(
    sentry_release_name: "#{target_binary_range}+codepush:#{label}",
    dist_version: update_info[:label],
    platform: PLATFORMS::CODEPUSH
  )

  slack(
    **SLACK.CODEPUSH,
    pretext: "A new version uploaded via Fastlane!",
    payload: {
      "Environment": ENVIRONMENT.capitalize,
      "Target Binary Range": target_binary_range,
      "Label": label,
      "Mandatory": is_mandatory,
      "Download Url": download_url,
    }
  )
end

lane :codepush_ship_ios do
  properties = property_file_read(file: ENVIRONMENT_FILE)
  current_version = properties["APP_VERSION_IOS"]

  codepush_ship(
    current_version: current_version,
    project_name: CODEPUSH_IOS_PROJECT_NAME
  )

  target_binary_range, label, is_mandatory, download_url = codepush_get_update_info(deployment_key: CODEPUSH_IOS_KEY, app_version: current_version)

  sentry_upload_artifacts(
    sentry_release_name: "#{target_binary_range}+codepush:#{update_info[:label]}",
    dist_version: label,
    platform: PLATFORMS::CODEPUSH
  )

  slack(
    **SLACK.CODEPUSH,
    pretext: "A new version uploaded via Fastlane!",
    payload: {
      "Environment": ENVIRONMENT.capitalize,
      "Target Binary Range": target_binary_range,
      "Label": label,
      "Mandatory": is_mandatory,
      "Download Url": download_url,
    }
  )
end