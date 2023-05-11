lane :sentry_upload_artifacts do |options|
    sentry_release_name = options[:sentry_release_name]
    platform = options[:platform]
    dist_version = options[:dist_version].to_s

    if sentry_release_name.nil?
      UI.user_error!("Sentry release version not specified")
    end

    if dist_version.nil?
      UI.user_error!("Sentry distribution version not specified")
    end

    source_map_path = ''
    bundle_path = ''
    outfile = ''

    if platform == PLATFORMS::IOS
      source_map_path = 'dist/ios/bundle.ios.js.map'
      bundle_path = 'dist/ios/bundle.ios.js'
      outfile = '~/bundle.ios.js'
    elsif platform == PLATFORMS::ANDROID
      source_map_path = 'dist/android/bundle.android.js.map'
      bundle_path = 'dist/android/bundle.android.js'
      outfile = '~/bundle.android.js'
    elsif platform == PLATFORMS::CODEPUSH
      source_map_path = 'dist/CodePush/main.jsbundle.map'
      bundle_path = 'dist/CodePush/main.jsbundle'
      outfile = '~/main.jsbundle'
    end

    UI.header "Sentry - Creating Release"

    # create a release in sentry
    sentry_create_release(
      **SENTRY_AUTH_PARAMS,
      version: sentry_release_name,
      finalize: false
    )

    # if platform is ios upload dSYM files
    if platform == "ios"
      UI.header "Sentry - Uploading dSYM Files"
      # make individual dSYM archives available to the sentry-cli tool.
      root = File.expand_path('../..', __dir__)
      dsym_archive = File.join(root, "#{IOS_BUILD_NAME}.app.dSYM.zip")
      dsyms_path = File.join(root, 'dSYMs')
      sh "unzip -d #{dsyms_path} #{dsym_archive}"

      Dir.glob(File.join(dsyms_path, '*.dSYM')).each do |dsym_path|
        # No need to specify `dist` as the build number is encoded in the dSYM's Info.plist
        sentry_upload_dsym(
          **SENTRY_AUTH_PARAMS,
          dsym_path: dsym_path
        )
      end
    end

    UI.header "Sentry - Sending Bundle File"

    # send bundle file
    sentry_upload_file(
      **SENTRY_AUTH_PARAMS,
      version: sentry_release_name,
      dist: dist_version,
      file: bundle_path,
      file_url: outfile
    )

    UI.header "Sentry - Sending Sourcemap File"

    # send sourcemap file
    sentry_upload_sourcemap(
      **SENTRY_AUTH_PARAMS,
      version: sentry_release_name,
      dist: dist_version,
      sourcemap: source_map_path,
      rewrite: true
    )
  end