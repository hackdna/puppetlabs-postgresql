# frozen_string_literal: true

require 'spec_helper'

describe 'postgresql::server::service' do
  include_examples 'Ubuntu 18.04'

  let :pre_condition do
    'include postgresql::server'
  end

  it { is_expected.to contain_class('postgresql::server::service') }
  it { is_expected.to contain_service('postgresqld').with_name('postgresql').with_status('/usr/sbin/service postgresql@*-main status') }
end
