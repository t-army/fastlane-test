module MENU
  BUILD_ANDROID_EMULATOR = 0
  BUILD_IOS_SIMULATOR = 1
  BUILD_FOR_APP_STORE = 2
  BUILD_FOR_GOOGLE_PLAY = 3
  PROMOTE_ANDROID_INTERNAL = 4
  PROMOTE_IOS_TESTFLIGHT = 5
  CODEPUSH_UPDATE = 6
  DOCTOR = 7
  CLEAR_CACHE = 8
end

module ENVIRONMENTS
  STAGING = "staging"
  PRODUCTION = "production"
end

module PLATFORMS
  ANDROID = 0
  IOS = 1
  CODEPUSH = 2
end

module CLEAR_OPTIONS
  ANDROID = 0
  IOS = 1
  ALL = 2
  ALL_EXTREME = 3
end

module VERSION_SELECTIONS
  PATCH = 0
  MINOR = 1
  MAJOR = 2
  KEEP = 3
  CUSTOM = 4
end

module ICONS
  TESTFLIGHT = "https://firebasestorage.googleapis.com/v0/b/popile-firebase-staging.appspot.com/o/slack%2Ftestflight.png?alt=media&token=9d244963-8f7c-4038-ac0d-17fe03253b78"
  GOOGLE_PLAY = "https://firebasestorage.googleapis.com/v0/b/popile-firebase-staging.appspot.com/o/slack%2Fgoogle-play.png?alt=media&token=fa0d65c5-7cd7-4e53-a9e8-2b62bb9551f0"
  CODEPUSH = "https://firebasestorage.googleapis.com/v0/b/popile-firebase-staging.appspot.com/o/slack%2Fcodepush.png?alt=media&token=05c9bc42-ba7b-4932-8449-04faf1207e3b"
end