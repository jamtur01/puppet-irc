require 'spec_helper'

describe 'irc' do
  context 'on Puppet OpenSource' do
    let(:params) { { 
      :irc_server      => 'irc.example.org',
      :use_ssl         => false,
      :register_first  => false,
      :show_joins      => false,
      :puppet_confdir  => '/etc/puppet',
      :gem_provider    => 'gem'
    } }

    it { should contain_package('carrier-pigeon').with_provider('gem') }
  end

  context 'on Puppet Enterprise' do
    let(:params) { { 
      :irc_server      => 'irc.example.org',
      :use_ssl         => false,
      :register_first  => false,
      :show_joins      => false,
      :puppet_confdir  => '/etc/puppetlabs/puppet',
      :gem_provider    => 'pe_gem'
    } }

    it { should contain_package('carrier-pigeon').with_provider('pe_gem') }
  end
end
