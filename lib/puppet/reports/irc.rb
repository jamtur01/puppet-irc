require 'puppet'
require 'yaml'
require 'json'
require 'uri'
require 'net/https'

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
  CONFIG = YAML.load_file(configfile)

  desc <<-DESC
  Send notification of failed reports to an IRC channel and if configured create a Gist with the log output.
  DESC

  def process
    if self.status == 'failed'
      output = []
      self.logs.each do |log|
        output << log
      end
      if self.environment.nil?
        self.environment == 'production'
      end
      if CONFIG[:github_user] && CONFIG[:github_password]
        gist_id = gist(self.host,output)
        message = "Puppet #{self.environment} run for #{self.host} #{self.status} at #{Time.now.asctime}. Created a Gist showing the output at #{gist_id}"
      else
        Puppet.info "No GitHub credentials provided in irc.yaml - cannot create Gist with log output."
        message = "Puppet #{self.environment} run for #{self.host} #{self.status} at #{Time.now.asctime}."
      end

      max_attempts = 2
      begin
        timeout(8) do
          Puppet.debug "Sending status for #{self.host} to IRC."
          params  = {
            :uri     => CONFIG[:irc_server],
            :message => message,
            :ssl     => CONFIG[:irc_ssl],
            :register_first => CONFIG[:irc_register_first],
            :join    => CONFIG[:irc_join],
          }
          if CONFIG.has_key?(:irc_password)
            params[:channel_password] = CONFIG[:irc_password]
          end
          CarrierPigeon.send(params)
        end
      rescue Timeout::Error
         Puppet.notice "Failed to send report to #{CONFIG[:irc_server]} retrying..."
         max_attempts -= 1
         if max_attempts > 0
           retry
         else
           Puppet.err "Failed to send report to #{CONFIG[:irc_server]}"
         end
      end
    end
  end

  def gist(host,output)
    max_attempts = 2
    begin
      timeout(8) do
        https = Net::HTTP.new('api.github.com', 443)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.start {
          req = Net::HTTP::Post.new('/gists')
          req.basic_auth "#{CONFIG[:github_user]}", "#{CONFIG[:github_password]}"
          req.content_type = 'application/json'
          req.body = JSON.dump({
            "files" => { "#{host}-#{Time.now.to_i.to_s}" => { "content" => output.join("\n") } },
            "description" => "Puppet #{environment} run failed on #{host} @ #{Time.now.asctime}",
            "public" => false
          })
          response = https.request(req)
          gist_id = JSON.parse(response.body)["html_url"]
        }
      end
    rescue Timeout::Error
      Puppet.notice "Timed out while attempting to create a GitHub Gist, retrying ..."
      max_attempts -= 1
      if max_attempts > 0
        retry
      else
        Puppet.err "Timed out while attempting to create a GitHub Gist."
      end
    end
  end
end
