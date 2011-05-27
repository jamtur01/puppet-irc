require 'puppet'

begin
  require 'shout-bot'
rescue LoadError => e
  Puppet.info "You need the `shout-bot` gem to use the IRC report"
end

Puppet::Reports.register_report(:irc) do

IRC = "irc://puppetbot:password@irc.freenode.net:6667/#puppet"

  desc <<-DESC
  Send report information to an IRC channel.
  DESC

  def process
    if self.status == 'failed'
      Puppet.debug "Sending status for #{self.host} to IRC #{IRC}"
      ShoutBot.shout("#{IRC}") do |channel|
        channel.say "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}"
      end
    end
  end
end
