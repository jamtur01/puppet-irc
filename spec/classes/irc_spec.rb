require 'spec_helper'

describe 'irc' do
  it { should contain_package('carrier-pigeon').with_provider('gem') }

  context 'on Puppet Enterprise' do
    let(:facts) { {:is_pe => true} }

    it { should contain_package('carrier-pigeon').with_provider('pe_gem') }
  end
end
