require 'puppet'
require 'json'

class PanosTask
  def initialize
    # work around the fact that bolt (for now, see BOLT-132) is not able to transport additional code from the module
    # this requires that the panos module is pluginsynced to the node executing the task
    Puppet.settings.initialize_app_defaults(
      Puppet::Settings.app_defaults_for_run_mode(
        Puppet::Util::RunMode[:agent],
      ),
    )
    $LOAD_PATH.unshift(Puppet[:plugindest])

    unless target
      puts "Panos task must be run on a proxy"
      exit 1
    end

    add_plugin_paths(params['_installdir'])
  end

  def transport
    require 'puppet/resource_api/transport'
    require 'puppet/transport/panos'

    Puppet::ResourceApi::Transport.connect('panos', credentials)
  end

  def params
    @params ||= JSON.parse(ENV['PARAMS'] || STDIN.read)
  end

  def target
    @target ||= params['_target']
  end

  def credentials
    @credentials ||= if target.key? 'apikey'
                        {
                          host: target['host'],
                          apikey: target['apikey']
                        }
                      else
                        {
                          host: target['host'],
                          user: target['user'],
                          password: target['password']
                        }
                      end

    if target.key? 'port'
      @credentials[:port] = target['port']
    end

    @credentials
  end

  private
  # Syncs across anything from the module lib
  def add_plugin_paths(install_dir)
    Dir.glob(File.join([install_dir, '*'])).each do |mod|
      $LOAD_PATH << File.join([mod, "lib"])
    end
  end
end