kit = require 'nokit'

{Promise} = kit

module.exports = (task, option) ->
  prepareBuild = (opts) ->
    installTask(opts).then ->
      kit.exec 'find . -name ".DS_Store" -type f -delete'

  ##
  # Options
  ##
  option '-q --quick', 'Will not run the optional tasks.'

  ##
  # Tasks
  ##
  task 'install', 'Install dependences.', installTask = (opts = {}) ->
    if opts.quick
      Promise.resolve()
    else
      kit.spawn 'yarn'
      .catch ->
        kit.spawn 'npm', ['install']

  task 'update-lint',
    'Update eslint-config-airbnb to the newest version.', updateLintTask = ->
    # ref: https://www.npmjs.com/package/eslint-config-airbnb
    kit.exec '(
      export PKG=eslint-config-airbnb;
      npm info "$PKG@latest" peerDependencies --json |
      command sed "s/[\{\},]//g ; s/: /@/g" |
      xargs yarn add "$PKG@latest" -D --save
    )'
    .then ({code, stdout}) ->
      kit.log stdout

  task 'dev', 'Auto rebuild during development.', devTask = (opts) ->
    prepareBuild(opts).then ->
      kit.spawn 'webpack', ['--watch', '--progress'], {
        env: {
          NODE_ENV: 'development'
        }
      }

  task 'prod', 'Build for production environment.', (opts) ->
    prepareBuild(opts).then ->
      kit.spawn 'webpack', ['--progress'], {
        env: {
          NODE_ENV: 'production'
        }
      }

  task 'default', 'Default for development.', ->
    devTask({
      quick: true
    })
