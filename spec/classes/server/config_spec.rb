# frozen_string_literal: true

require 'spec_helper'

describe 'postgresql::server::config' do
  let(:pre_condition) do
    'class { postgresql::server: manage_selinux => true }'
  end

  describe 'on RedHat 7' do
    include_examples 'RedHat 7'

    it 'has SELinux port defined' do
      is_expected.to contain_package('policycoreutils-python').with(ensure: 'installed')

      is_expected.to contain_exec('/usr/sbin/semanage port -a -t postgresql_port_t -p tcp 5432')
        .with(unless: '/usr/sbin/semanage port -l | grep -qw 5432')
        .that_comes_before('Postgresql::Server::Config_entry[port]')
        .that_requires('Package[policycoreutils-python]')
    end

    it 'removes the old systemd-override file' do
      is_expected.to contain_file('old-systemd-override')
        .with(ensure: 'absent', path: '/etc/systemd/system/postgresql.service')
    end

    it 'has the correct systemd-override drop file' do
      is_expected.to contain_file('systemd-override').with(
        ensure: 'file', path: '/etc/systemd/system/postgresql.service.d/postgresql.conf',
        owner: 'root', group: 'root'
      ) .that_requires('File[systemd-conf-dir]')
    end

    it 'has the correct systemd-override file #regex' do
      is_expected.to contain_file('systemd-override') \
        .with_content(%r{(?!^.include)})
    end

    context 'RHEL 7 host with Puppet 5' do
      include_examples 'RedHat 7'

      it 'has systemctl restart command' do
        is_expected.to contain_exec('restart-systemd').with(
          command: ['systemctl', 'daemon-reload'],
          refreshonly: true,
          path: '/bin:/usr/bin:/usr/local/bin',
        )
      end
    end

    describe 'with manage_package_repo => true and a version' do
      let(:pre_condition) do
        <<-EOS
          class { 'postgresql::globals':
            manage_package_repo => true,
            version => '9.4',
          }->
          class { 'postgresql::server': }
        EOS
      end

      it 'has the correct systemd-override file' do
        is_expected.to contain_file('systemd-override').with(
          ensure: 'file', path: '/etc/systemd/system/postgresql-9.4.service.d/postgresql-9.4.conf',
          owner: 'root', group: 'root'
        )
      end

      it 'has the correct systemd-override file #regex' do
        is_expected.to contain_file('systemd-override') .without_content(%r{\.include})
      end
    end
  end

  describe 'on Redhat 8' do
    include_examples 'RedHat 8'

    it 'has SELinux port defined' do
      is_expected.to contain_package('policycoreutils-python-utils').with(ensure: 'installed')

      is_expected.to contain_exec('/usr/sbin/semanage port -a -t postgresql_port_t -p tcp 5432')
        .with(unless: '/usr/sbin/semanage port -l | grep -qw 5432')
        .that_comes_before('Postgresql::Server::Config_entry[port]')
        .that_requires('Package[policycoreutils-python-utils]')
    end

    it 'removes the old systemd-override file' do
      is_expected.to contain_file('old-systemd-override')
        .with(ensure: 'absent', path: '/etc/systemd/system/postgresql.service')
    end

    it 'has the correct systemd-override drop file' do
      is_expected.to contain_file('systemd-override').with(
        ensure: 'file', path: '/etc/systemd/system/postgresql.service.d/postgresql.conf',
        owner: 'root', group: 'root'
      ) .that_requires('File[systemd-conf-dir]')
    end

    it 'has the correct systemd-override file #regex' do
      is_expected.to contain_file('systemd-override') .without_content(%r{\.include})
    end

    describe 'with manage_package_repo => true and a version' do
      let(:pre_condition) do
        <<-EOS
          class { 'postgresql::globals':
            manage_package_repo => true,
            version => '9.4',
          }->
          class { 'postgresql::server': }
        EOS
      end

      it 'has the correct systemd-override file' do
        is_expected.to contain_file('systemd-override').with(
          ensure: 'file', path: '/etc/systemd/system/postgresql-9.4.service.d/postgresql-9.4.conf',
          owner: 'root', group: 'root'
        )
      end
      it 'has the correct systemd-override file #regex' do
        is_expected.to contain_file('systemd-override') .without_content(%r{\.include})
      end
    end
  end

  describe 'on Fedora 33' do
    include_examples 'Fedora 33'

    it 'has SELinux port defined' do
      is_expected.to contain_package('policycoreutils-python-utils').with(ensure: 'installed')

      is_expected.to contain_exec('/usr/sbin/semanage port -a -t postgresql_port_t -p tcp 5432')
        .with(unless: '/usr/sbin/semanage port -l | grep -qw 5432')
        .that_comes_before('Postgresql::Server::Config_entry[port]')
        .that_requires('Package[policycoreutils-python-utils]')
    end

    it 'removes the old systemd-override file' do
      is_expected.to contain_file('old-systemd-override')
        .with(ensure: 'absent', path: '/etc/systemd/system/postgresql.service')
    end

    it 'has the correct systemd-override drop file' do
      is_expected.to contain_file('systemd-override').with(
        ensure: 'file', path: '/etc/systemd/system/postgresql.service.d/postgresql.conf',
        owner: 'root', group: 'root'
      ) .that_requires('File[systemd-conf-dir]')
    end

    it 'has the correct systemd-override file #regex' do
      is_expected.to contain_file('systemd-override') .without_content(%r{\.include})
    end

    describe 'with manage_package_repo => true and a version' do
      let(:pre_condition) do
        <<-EOS
          class { 'postgresql::globals':
            manage_package_repo => true,
            version => '13',
          }->
          class { 'postgresql::server': }
        EOS
      end

      it 'has the correct systemd-override file' do
        is_expected.to contain_file('systemd-override').with(
          ensure: 'file', path: '/etc/systemd/system/postgresql-13.service.d/postgresql-13.conf',
          owner: 'root', group: 'root'
        )
      end

      it 'has the correct systemd-override file #regex' do
        is_expected.to contain_file('systemd-override') .without_content(%r{\.include})
      end
    end
  end

  describe 'on Amazon' do
    include_examples 'Amazon 1'

    it 'has SELinux port defined' do
      is_expected.to contain_package('policycoreutils').with(ensure: 'installed')

      is_expected.to contain_exec('/usr/sbin/semanage port -a -t postgresql_port_t -p tcp 5432')
        .with(unless: '/usr/sbin/semanage port -l | grep -qw 5432')
        .that_comes_before('Postgresql::Server::Config_entry[port]')
        .that_requires('Package[policycoreutils]')
    end
  end

  describe 'with managed pg_hba_conf and ipv4acls' do
    include_examples 'RedHat 7'
    let(:pre_condition) do
      <<-EOS
        class { 'postgresql::globals':
          version => '9.5',
        }->
        class { 'postgresql::server':
          manage_pg_hba_conf => true,
          ipv4acls => [
            'hostnossl all all 0.0.0.0/0 reject',
            'hostssl all all 0.0.0.0/0 md5'
          ]
        }
      EOS
    end

    it 'has hba rule default' do
      is_expected.to contain_postgresql__server__pg_hba_rule('local access as postgres user')
    end
    it 'has hba rule ipv4acls' do
      is_expected.to contain_postgresql__server__pg_hba_rule('postgresql class generated rule ipv4acls 0')
    end
  end

  describe 'on Gentoo' do
    include_examples 'Gentoo'

    describe 'with systemd' do
      let(:facts) { super().merge(service_provider: 'systemd') }
      let(:pre_condition) do
        <<-EOS
          class { 'postgresql::globals':
            version => '9.5',
          }->
          class { 'postgresql::server': }
        EOS
      end

      it 'does not have SELinux port defined' do
        is_expected.not_to contain_exec('/usr/sbin/semanage port -a -t postgresql_port_t -p tcp 5432')
      end

      it 'removes the old systemd-override file' do
        is_expected.to contain_file('old-systemd-override')
          .with(ensure: 'absent', path: '/etc/systemd/system/postgresql-9.5.service')
      end

      it 'has the correct systemd-override drop file' do
        is_expected.to contain_file('systemd-override').with(
          ensure: 'file', path: '/etc/systemd/system/postgresql-9.5.service.d/postgresql-9.5.conf',
          owner: 'root', group: 'root'
        )
      end

      it 'has the correct systemd-override file #regex' do
        is_expected.to contain_file('systemd-override') \
          .with_content(%r{(?!^.include)})
      end
    end
  end
end
