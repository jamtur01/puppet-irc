require 'puppet'
require 'yaml'
require 'json'

begin
  require 'carrier-pigeon'
rescue LoadError => e
  Puppet.info "You need the `carrier-pigeon` gem to use the IRC report"
end

unless Puppet.version >= '2.6.5'
  fail "This report processor requires Puppet version 2.6.5 or later"
end

Puppet::Reports.register_report(:irc) do

  configfile = File.join([File.dirname(Puppet.settings[:config]), "irc.yaml"])
  raise(Puppet::ParseError, "IRC report config file #{configfile} not readable") unless File.exist?(configfile)
  @config = YAML.load_file(configfile)

  desc <<-DESC
  Send notification of failed reports to an IRC channel and if configured create a Gist with the log output.
  DESC

  def process
    if self.status == 'failed'
      output = []
      self.logs.each do |log|
        output << log
      end

      if @config[:github_user] && @config[:github_token]
        gist_id = gist(self.host,output)
        message = "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}. Created a Gist showing the output at https://gist.github.com/#{gist_id}"
      else
        Puppet.info "No GitHub credentials provided in irc.yaml - cannot create Gist with log output."
        message = "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}."
      end

      begin
        timeout(8) do
          Puppet.debug "Sending status for #{self.host} to IRC."
          params  = {
            :uri     => @config[:irc_server],
            :message => message,
            :ssl     => @config[:irc_ssl],
            :join    => true,
          }
          if @config.has_key?(:irc_password)
            params[:channel_password] = @config[:irc_password]
          end
          CarrierPigeon.send(params)
        end
      rescue Timeout::Error
         Puppet.error "Failed to send report to #{@config[:irc_server]} retrying..."
         max_attempts -= 1
         retry if max_attempts > 0
      end
    end
  end

  def gist(host,output)
    begin
      timeout(8) do
        res = Net::HTTP.post_form(URI.parse("http://gist.github.com/api/v1/json/new"), {
          "files[#{host}-#{Time.now.to_i.to_s}]" => output.join("\n"),
          "login" => @config[:github_user],
          "token" => @config[:github_token],
          "description" => "Puppet run failed on #{host} @ #{Time.now.asctime}",
          "public" => false
        })
        gist_id = JSON.parse(res.body)["gists"].first["repo"]
      end
    rescue Timeout::Error
      Puppet.error "Timed out while attempting to create a GitHub Gist, retrying ..."
      max_attempts -= 1
      retry if max_attempts > 0
    end
  end
end
