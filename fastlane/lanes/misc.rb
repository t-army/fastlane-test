prompt = TTY::Prompt.new

private_lane :flip_table do
  UI.header "Clear metro cache (┛ಠ_ಠ)┛彡┻━┻"
  sh 'rm -rf "$TMPDIR"/metro* .metro'

  UI.header "Clear gems (┛ಠ_ಠ)┛彡┻━┻┻"
  sh "rm -rf .vendor"

  UI.header "Clear node modules (┛ಠ_ಠ)┛彡┻━┻"
  sh "rm -rf node_modules"

  UI.header "Clear jest cache (┛◉Д◉)┛彡┻━┻"
  sh "rm -rf .jest"

  UI.header "Clear build artefacts (╯ರ ~ ರ）╯︵ ┻━┻"
  sh "rm -rf dist"

  UI.header "Reinstall dependencies ┬─┬ノ( º _ ºノ)"
  sh "yarn && yarn run pod-install"
end

private_lane :parse_version do |options|
  version = options[:version]
  pattern = /\d\.\d\.\d/

  if version.match?(pattern)
    version = version.match(pattern)[0]
  else
    UI.user_error!("Whoops, current version not parsable!")
  end

  parts = version.split(".")

  major = parts[0]
  minor = parts[1]
  patch = parts[2]

  target_major = (major.to_i + 1).to_s + ".0.0"
  target_minor = major + "." + (minor.to_i + 1).to_s + ".0"
  target_patch = major + "." + minor + "." + (patch.to_i + 1).to_s

  [target_major, target_minor, target_patch]
end

private_lane :select_version do |options|
  current_version = options[:version]
  target_major, target_minor, target_patch = parse_version(version: current_version)
  version_ok = false

  while version_ok === false
    target_version_selection = prompt.select("What version do you want to use?", [
      {value: VERSION_SELECTIONS::PATCH, name: "Bump patch (#{target_patch})"},
      {value: VERSION_SELECTIONS::MINOR, name: "Bump minor (#{target_minor})"},
      {value: VERSION_SELECTIONS::MAJOR, name: "Bump major (#{target_major})"},
      {value: VERSION_SELECTIONS::KEEP, name: "KEEP EXISTING (#{current_version})"},
      {value: VERSION_SELECTIONS::CUSTOM, name: "CUSTOM"},
    ])

    if target_version_selection === VERSION_SELECTIONS::CUSTOM
      custom_version = prompt(text: "\nEnter New Version Number:")

      if custom_version < current_version
        UI.important "Wahaha, version (#{custom_version}) can't lower than the current version (#{current_version})"
      else
        version_ok = true
      end
    else
      version_ok = true
    end
  end

  next target_major if target_version_selection === VERSION_SELECTIONS::MAJOR
  next target_minor if target_version_selection === VERSION_SELECTIONS::MINOR
  next target_patch if target_version_selection === VERSION_SELECTIONS::PATCH
  next current_version if target_version_selection === VERSION_SELECTIONS::KEEP

  custom_version
end