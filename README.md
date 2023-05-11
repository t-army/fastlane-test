# Global Configuration File for Popile Mobile Apps

This configuration file is prepared for use in Popile's React-Native projects.

## Benefits

The following features are provided with Fastlane:

- Interactive task execution, execute pre-defined tasks just using arrow keys
- Ability to build and upload your app for Google Play and App Store
- Ability to build your app for Android Emulator and iOS Simulator
- Automatic managment for app version and build number
- Codepush support, you can release via Codepush
- Sentry support, send your source and symbol files to Sentry
- Send messages to desired Slack channels when publishing is complete
- Doctor script, see whats wrong with your development environment
- Clear cache assets to size your harddisk volume up

The following features are provided with EsLint:

- Enforce order of imports
- Enforce order of exports
- Enforce order of styles

The following features are provided with SVGR configuration:

- Ability create svg components from svg files

## Getting Started

The configuration consists of many different parts.

### Environment Files

You need to create 3 different environment variable files in your project root directory;

- `.env.secrets`
- `.env.production`
- `.env.staging`

In `.env.secrets` file we keep all fastlane related configuration. For an example this file contains App Store and Google Play secrets. Therefore keeping this file separate is very very important.

`.env.secrets` file example:

```env
CODEPUSH_ORGANIZATION_NAME=
CODEPUSH_ANDROID_PROJECT_NAME=
CODEPUSH_IOS_PROJECT_NAME=
CODEPUSH_API_TOKEN=
APP_STORE_KEY_ID=
APP_STORE_ISSUER_ID=
APP_STORE_KEY_CONTENT_BASE64=
SENTRY_ORG_SLUG=
SENTRY_PROJECT_SLUG=
SENTRY_AUTH_TOKEN=
PLAY_STORE_CONFIG_JSON=
SLACK_WEBHOOK_URL=
```

`.env.production` and `.env.staging` file example:

```env
ENVIRONMENT=
APP_BUNDLE_ID=
APP_PACKAGE_NAME=
APP_DISPLAY_NAME=
APP_VERSION_ANDROID=
APP_VERSION_IOS=
APP_BUILD_NUMBER_ANDROID=
APP_BUILD_NUMBER_IOS=
CODEPUSH_IOS=
CODEPUSH_ANDROID=
CODEPUSH_CHANNEL_NAME=
IOS_XCWORKSPACE=
IOS_XCODEPROJ=
IOS_SCHEME=
IOS_TARGET=
IOS_BUILD_NAME=
ANDROID_FLAVOR=
```

Some Notes:

- `ENVIRONMENT` key should be `staging` or `production` based file
- `APP_VERSION_ANDROID` and `APP_VERSION_IOS` should be semantic versioning format, for an example 1.0.0

### Versioning

...

### Fastlane

- Create `Fastfile` file under `fastlane` directory:

```ruby
import_from_git(url: 'https://github.com/t-army/fastlane-test.git', branch: "HEAD", path: "fastlane/Fastfile")
```

- Also create a `Pluginfile` file under `fastlane` directory:

```Gemfile
gem 'fastlane-plugin-property_file_read'
gem 'fastlane-plugin-appcenter'
gem 'fastlane-plugin-sentry'
gem 'fastlane-plugin-properties'
```

- Add below lines to your `Gemfile`:

```Gemfile
gem 'fastlane'
gem "tty-prompt", "~> 0.23.1"

# install necessary fastlane plugins
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

- Install required gems:

```bash
# ensure bundler version (must be >=2.x.x)
gem list bundler

# if your bundler version lower than required version, run below command
sudo gem install bundler

# install gems
bundle install
```

- Add a npm script to your project:

```bash
npm pkg set scripts.interactive="bundle exec fastlane interactive"
```

- You're ready to use the fastlane configuration with below command:

```bash
yarn run interactive
```