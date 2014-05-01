require 'spec_helper'

describe 'irc' do
  context 'on Puppet OpenSource' do
    let(:params) { { 
      :irc_server      => 'irc.example.org',
    } }

    it { should contain_package('carrier-pigeon').with_provider('gem') }
  end

  context 'on Puppet Enterprise' do
    let(:params) { { 
      :irc_server      => 'irc.example.org',
    } }

    let(:facts) { {:is_pe => true } }

    it { should contain_package('carrier-pigeon').with_provider('pe_gem') }
  end
end
