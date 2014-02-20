# = Class: irc
#
# A puppet report processor that announces failed runs to IRC.
#
# This class installs and sets up the report processor on your Puppet Master.
#
# == Actions:
#   - install carrier-pigeon gem
#   - template irc.yaml configuration file
#
# === Parameters:
#
# [*irc_server*]
#   (string) IRC server URI containing channel connection details,
#   Example: irc://puppetbot:password@irc.freenode.net:6667#channel
#
# [*use_ssl*]
#   (boolean) whether to use SSL to connect to IRC
#   (default: false)
#
# [*channel_password*]
#   (string or undef) channel password, if required
#   (default: undef)
#
# [*register_first*]
#   (boolean) set to true if you get 'register_first' error
#   (default: false)
#
# [*show_joins*]
#   (boolean) whether or not to show parts/joins/quits messages
#   (default: true)
#
# [*github_user*]
#   (string or undef) github username. If specified, the report processor will create
#   a Gist containing the log output from the run and link it in the IRC
#   notification.
#   (default: undef)
#
# [*github_password*]
#   (string or undef) password for github_user
#   (default: undef)
#
# [*parsed_reports_dir*]
#   (string or undef) path to a directory on the reportserver. If specified, a
#   human-readable version of the report will be saved in this directory, and
#   it's path will be mentioned in the IRC notification. Don't forget to create
#   the directory on your reportserver, writeable to the user running the
#   puppet-master, and setup a job to clean old reports.
#   (default: undef)
#
# [*report_url*]
#   (string or undef) an URL, which if specified, will be appended to the IRC
#   notification. Some special characters will be expanded to values found in the
#   report.
#
#   Example:
#   http://foreman.example.com/hosts/%h/reports/last
#
#   Currently supported characters include:
#   * `%c`: configuration version string
#   * `%e`: puppet's run environment
#   * `%h`: host name from puppet
#   * `%k`: kind of report
#   * `%s`: report status
#   * `%t`: report timestamp
#   * '%v`: puppet version
#
# [*puppet_user*]
#   (string) the user that puppet master runs as, and owner of the config file
#   (default: 'puppet')
#
# [*puppet_confdir*]
#   (string) path to the puppet configuration directory on disk,
#   irc.yaml will be written inside this directory
#   (default '/etc/puppet')
#
# == Sample Usage:
#
#    class { 'ircreporter':
#      irc_server  => 'irc://puppetbot:password@irc.freenode.net:6667#channel',
#      report_url  => 'http://foreman.example.com/hosts/%h/reports/last',
#    }
#
# Or something similar using your ENC. Then enable the report processor (see README.md)
#
# == Notes:
#
# == Author:
#
# Jason Antman <jason@jasonantman.com>
#
class irc (
  $irc_server         = undef,
  $use_ssl            = false,
  $channel_password   = undef,
  $register_first     = false,
  $show_joins         = true,
  $github_user        = undef,
  $github_password    = undef,
  $parsed_reports_dir = undef,
  $report_url         = undef,
  $puppet_user        = 'puppet',
  $puppet_confdir     = '/etc/puppet'
){

  validate_string($irc_server)
  validate_bool($use_ssl)
  validate_bool($register_first)
  validate_bool($show_joins)
  validate_string($puppet_user)
  validate_absolute_path($puppet_confdir)

  package {'carrier-pigeon':
    ensure   => present,
    provider => gem,
  }

  # Template Uses:
  # - $irc_server
  # - $use_ssl
  # - $channel_password
  # - $register_first
  # - $show_joins
  # - $github_user
  # - $github_password
  # - $parsed_reports_dir
  # - $report_url
  #
  file {'ircreporter-yaml-config':
    ensure  => present,
    path    => "${puppet_confdir}/irc.yaml",
    mode    => 0640,
    owner   => $puppet_user,
    group   => 'root',
    content => template('ircreporter/irc.yaml.erb'),
  }

}
