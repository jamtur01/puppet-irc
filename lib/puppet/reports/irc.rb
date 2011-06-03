require 'puppet'
require 'yaml'
require 'json'

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
  GITHUB_USER = config[:github_user]
  GITHUB_TOKEN = config[:github_token]

  desc <<-DESC
  Send notification of failed reports to an IRC channel and if configured create a Gist with the log output.
  DESC

  def process
    if self.status == 'failed'
      output = []
      self.logs.each do |log|
        output << log
      end

      if GITHUB_USER && GITHUB_TOKEN
        gist_id = gist(self.host,output)
        say = "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}. Created a Gist showing the output at https://gist.github.com/#{gist_id}"
      else
        Puppet.info "No GitHub credentials provided in irc.yaml - cannot create Gist with log output."
        say = "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}."
      end

      ShoutBot.shout("#{IRC_SERVER}") do |channel|
        Puppet.debug "Sending status for #{self.host} to IRC."
        channel.say "#{say}"
      end
    end
  end

  def gist(host,output)
    begin
      timeout(8) do
        res = Net::HTTP.post_form(URI.parse("http://gist.github.com/api/v1/json/new"), {
          "files[#{host}-#{Time.now.to_i.to_s}]" => output.join("\n"),
          "login" => GITHUB_USER,
          "token" => GITHUB_TOKEN,
          "description" => "Puppet run failed on #{host} @ #{Time.now.asctime}",
          "public" => false
        })
        gist_id = JSON.parse(res.body)["gists"].first["repo"]
      end
    rescue Timeout::Error
      Puppet.error("Timed out while attempting to create a GitHub Gist, retrying ...")
      max_attempts -= 1
      retry if max_attempts > 0
    end
  end
end
