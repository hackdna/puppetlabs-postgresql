# frozen_string_literal: true

require 'spec_helper'

describe 'postgresql::validate_db_connection' do
  include_examples 'Debian 11'

  let :title do
    'test'
  end

  describe 'should work with only default parameters' do
    it { is_expected.to contain_postgresql__validate_db_connection('test') }
  end

  describe 'should work with all parameters' do
    let :params do
      {
        database_host: 'test',
        database_name: 'test',
        database_password: 'test',
        database_username: 'test',
        database_port: 5432,
        run_as: 'postgresq',
        sleep: 4,
        tries: 30,
      }
    end

    it { is_expected.to contain_postgresql__validate_db_connection('test') }

    it 'has proper path for validate command' do
      is_expected.to contain_exec('validate postgres connection for test@test:5432/test').with(unless: ['/usr/local/bin/validate_postgresql_connection.sh',
                                                                                                        4,
                                                                                                        30,
                                                                                                        '/usr/bin/psql --tuples-only --quiet -h test -U test -p 5432 --dbname test'])
    end
  end

  describe 'should work while specifying validate_connection in postgresql::client' do
    let :params do
      {
        database_host: 'test',
        database_name: 'test',
        database_password: 'test',
        database_username: 'test',
        database_port: 5432,
      }
    end

    let :pre_condition do
      <<-MANIFEST
        class { 'postgresql::globals':
          module_workdir => '/var/tmp',
        } ->
        class { 'postgresql::client': validcon_script_path => '/opt/something/validate.sh' }
      MANIFEST
    end

    it 'has proper path for validate command and correct cwd' do
      is_expected.to contain_exec('validate postgres connection for test@test:5432/test').with(unless: ['/opt/something/validate.sh',
                                                                                                        2,
                                                                                                        10,
                                                                                                        '/usr/bin/psql --tuples-only --quiet -h test -U test -p 5432 --dbname test'],
                                                                                               cwd: '/var/tmp')
    end
  end
end
