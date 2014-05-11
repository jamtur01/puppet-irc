class irc::params {

  $irc_server         = undef
  $use_ssl            = false
  $channel_password   = undef
  $register_first     = false
  $show_joins         = true
  $github_user        = undef
  $github_password    = undef
  $parsed_reports_dir = undef
  $report_url         = undef

  if $::is_pe { 
    $puppet_user        = 'pe-puppet'
    $puppet_confdir     = '/etc/puppetlabs/puppet'
    $gem_provider       = 'pe_gem'
  } else { 
    $puppet_user        = 'puppet'
    $puppet_confdir     = '/etc/puppet'
    $gem_provider       = 'gem'
  }
}
