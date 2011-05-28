require 'puppet'
require 'yaml'

begin
  require 'shout-bot'
rescue LoadError => e
  Puppet.info "You need the `shout-bot` gem to use the IRC report"
end

Puppet::Reports.register_report(:irc) do

  configfile = File.join([File.dirname(Puppet.settings[:config]), "irc.yaml"])
  raise(Puppet::ParseError, "IRC report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)
  IRC_SERVER = config[:irc_server]
  IRC_CHANNEL = config[:irc_channel]

  desc <<-DESC
  Send notification of failed reports to an IRC channel.
  DESC

  def process
    if self.status == 'failed'
      Puppet.debug "Sending status for #{self.host} to IRC #{IRC_SERVER} and channel #{IRC_CHANNEL}"
      ShoutBot.shout("#{IRC_SERVER}/#{IRC_CHANNEL}") do |channel|
        channel.say "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}"
      end
    end
  end
end
