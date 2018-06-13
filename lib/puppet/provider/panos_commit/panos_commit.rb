require 'puppet/resource_api/simple_provider'

# Implementation for the panos_commit type using the Resource API.
class Puppet::Provider::PanosCommit::PanosCommit
  def get(context)
    [
      {
        name: 'commit',
        # return a value that causes an update if the user requested one
        commit: !context.device.outstanding_changes?,
      },
    ]
  end

  def set(context, changes)
    if context.device.outstanding_changes?
      if changes['commit'][:should][:commit]
        context.updating('commit') do
          context.device.commit
        end
      else
        context.info('changes detected, but skipping commit as requested')
      end
    else
      context.debug('no changes detected')
    end
  end
end
