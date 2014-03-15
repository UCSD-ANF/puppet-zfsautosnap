class zfsautosnap::client (
  $target_hostname,
  $client_ssh_privkey_source,
  $client_ssh_privkey_name='id_dsa',
  $target_username='zfsbackup',
  $target_pool = 'zfsbackups',
  $verbose_daily = false,
  $verbose_hourly = false,
  $enable_hourly = true,
  $enable_daily = true
) {
  validate_bool($enable_daily)
  validate_bool($verbose_daily)
  validate_bool($enable_hourly)
  validate_bool($verbose_hourly)
  include zfsautosnap

  $client_username = 'zfssnap' # Created by the package installation
  $client_groupname = 'other'  # Specified by package
  $client_homedir = "/export/home/${client_username}"

  $basefmri = 'svc:/system/filesystem/zfs/auto-snapshot'

  package { 'IGPPzfsautosnap':
    ensure   => 'installed',
    require  => Package['mbuffer'],
  } ->
  user { $client_username :
    ensure   => 'role',
    uid      => '51',
    comment  => 'ZFS Automatic Snapshots role',
    gid      => 'other',
    shell    => '/bin/pfsh',
    home     => $client_homedir,
    password => 'NP',
  } ->
  file { $client_homedir :
    ensure => 'directory',
    owner  => $client_username,
    group  => $client_groupname,
    mode   => '0755',
  } ->
  file { "${client_homedir}/.ssh" :
    ensure => 'directory',
    owner  => $client_username,
    group  => $client_groupname,
    mode   => '0755',
  } ->
  file { 'zfsbackups client ssh privkey':
    ensure => 'file',
    source => $client_ssh_privkey_source,
    path   => "${client_homedir}/.ssh/${client_ssh_privkey_name}",
    owner  => $client_username,
    group  => $client_groupname,
    mode   => '0700',
  }

  file { '/usr/local/sbin/checkzfssnaplock':
    ensure  => 'present',
    source  => 'puppet:///zfsautosnap/checkzfssnaplock',
    owner   => 'root',
    group   => 'sys',
    mode    => '0755',
    require => File['/usr/local/sbin'],
  }

  file { '/usr/local/sbin/clearzfssnaplock':
    ensure => 'present',
    source => 'puppet:///zfsautosnap/clearzfssnaplock',
    owner  => 'root',
    group  => 'sys',
    mode   => '0755',
    require => File['/usr/local/sbin'],
  }

  svcprop { 'zfssnap daily type':
    fmri     => "${basefmri}:daily",
    property => 'zfs/backup',
    value    => 'incremental_mbuffered',
    require  => Package['IGPPzfsautosnap'],
  }

  svcprop { 'zfssnap daily host':
    fmri     => "${basefmri}:daily",
    property => 'zfs/backup-host',
    value    => $target_hostname,
    require  => Package['IGPPzfsautosnap'],
  }

  svcprop { 'zfssnap daily zpool':
    fmri     => "${basefmri}:daily",
    property => 'zfs/backup-zpool',
    value    => $target_pool,
    require  => Package['IGPPzfsautosnap'],
  }

  svcprop { 'zfssnap daily user':
    fmri     => "${basefmri}:daily",
    property => 'zfs/backup-user',
    value    => $target_username,
    require  => Package['IGPPzfsautosnap'],
  }

  service { "${basefmri}:daily" :
    enable  => $enable_daily,
    require => Package['IGPPzfsautosnap'],
  } ->
  svcprop { 'zfssnap daily verbose':
    fmri     => "${basefmri}:daily",
    property => 'zfs/verbose',
    value    => $verbose_daily,
  }
  service { "${basefmri}:hourly" :
    enable  => $enable_hourly,
    require => Package['IGPPzfsautosnap'],
  } ->
  svcprop { 'zfssnap hourly verbose':
    fmri     => "${basefmri}:hourly",
    property => 'zfs/verbose',
    value    => $verbose_hourly,
  }
  service { "${basefmri}:monthly" :
    enable  => false,
    require => Package['IGPPzfsautosnap'],
  }
  service { "${basefmri}:weekly" :
    enable  => false,
    require => Package['IGPPzfsautosnap'],
  }
  service { "${basefmri}:frequent" :
    enable  => false,
    require => Package['IGPPzfsautosnap'],
  }
  service { "${basefmri}:event" :
    enable  => false,
    require => Package['IGPPzfsautosnap'],
  }

}
