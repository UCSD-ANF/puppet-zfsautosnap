class zfsautosnap::client (
  $target_hostname,
  $client_ssh_privkey_source,
  $client_ssh_privkey_name='id_dsa',
  $target_username='zfsbackup',
  $target_pool = 'zfsbackups'
) {
  include zfsautosnap

  $client_username = 'zfssnap' # Created by the package installation
  $client_homedir = "/export/home/${client_username}"

  $basefmri = 'svc:/system/filesystem/zfs/auto-snapshot'

  package { 'IGPPzfsbackup':
    ensure  => 'installed',
    require => Package['mbuffer'],
  } ->
  file { 'zfsbackups client ssh privkey':
    ensure => 'file',
    source => $client_ssh_privkey_source,
    path   => "${client_homedir}/.ssh/${client_ssh_privkey_name}",
  }

  svcprop { 'zfssnap daily type':
    fmri     => "${basefmri}:daily",
    property => 'zfs/backup',
    value    => 'incremental_mbuffered',
    require  => Package['IGPPzfsbackup'],
  }

  svcprop { 'zfssnap daily host':
    fmri     => "${basefmri}:daily",
    property => 'zfs/backup-host',
    value    => $target_hostname,
    require  => Package['IGPPzfsbackup'],
  }

  svcprop { 'zfssnap daily zpool':
    fmri     => "${basefmri}:daily",
    property => 'zfs/backup-zpool',
    value    => $target_pool,
    require  => Package['IGPPzfsbackup'],
  }

  svcprop { 'zfssnap daily user':
    fmri     => "${basefmri}:daily",
    property => 'zfs/backup-user',
    value    => $target_username,
    require  => Package['IGPPzfsbackup'],
  }

  service { "${basefmri}:daily" :
    ensure  => 'enabled',
    require => Package['IGPPzfsbackup'],
  }
  service { "${basefmri}:hourly" :
    ensure  => 'enabled',
    require => Package['IGPPzfsbackup'],
  }
  service { "${basefmri}:monthly" :
    ensure  => 'disabled',
    require => Package['IGPPzfsbackup'],
  }
  service { "${basefmri}:weekly" :
    ensure  => 'disabled',
    require => Package['IGPPzfsbackup'],
  }
  service { "${basefmri}:frequent" :
    ensure  => 'disabled',
    require => Package['IGPPzfsbackup'],
  }
  service { "${basefmri}:event" :
    ensure  => 'disabled',
    require => Package['IGPPzfsbackup'],
  }

}
