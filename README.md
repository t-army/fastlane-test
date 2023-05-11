# Setup

## Fastlane

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