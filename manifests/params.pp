class irc::params {

  $irc_server         = undef
  $use_ssl            = false
  $channel_password   = undef
  $register_first     = false
  $show_joins         = true
  $timeout            = undef
  $github_user        = undef
  $github_password    = undef
  $parsed_reports_dir = undef
  $report_url         = undef

  # assume that the master this is being enforced on is the same configuration as the one compiling
  $puppet_confdir     = $::settings::confdir
  $puppet_user        = $::settings::user

  if $::pe_server_version {
    $gem_provider     = 'puppetserver_gem'
  }
  elsif str2bool($::is_pe) {
    if versioncmp($::pe_version, '3.7.0') > 0 {
        $gem_provider = 'pe_puppetserver_gem'
      }
      else {
        $gem_provider = 'pe_gem'
    }
  } else {
    $gem_provider     = 'gem'
  }
}
