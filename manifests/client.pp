# Set up a ZFS autosnap client
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
  ## Parameter validation
  validate_bool($enable_daily)
  validate_bool($verbose_daily)
  validate_bool($enable_hourly)
  validate_bool($verbose_hourly)

  require zfsautosnap

  ## Internal variables
  $client_username = 'zfssnap' # Created by the package installation
  $client_groupname = $::osfamily ? {
    'Solaris' => 'other',  # Specified by zfsautosnap package
    default   => 'daemon',
  }
  $client_homedir = "/export/home/${client_username}"
  $client_shell = $::osfamily ? {
    'Solaris' => '/bin/pfsh',
    'FreeBSD' => '/usr/local/bin/bash',
    default   => '/bin/bash',
  }

  $client_user_ensure = $::osfamily ? {
    'Solaris' => 'role',
    default   => 'present',
  }

  # # Used by the old Solaris package only
  # $basefmri = 'svc:/system/filesystem/zfs/auto-snapshot'

  # $verbose_daily_real = $verbose_daily ? {
  #   true  => 'true',
  #   false => 'false',
  # }

  # $verbose_hourly_real = $verbose_hourly ? {
  #   true  => 'true',
  #   false => 'false',
  # }

  ## Managed resources
  #  package { 'IGPPzfsautosnap':
  #  ensure  => 'installed',
  #  require => Package['mbuffer'],
  #} ->
  user { $client_username :
    ensure   => $client_user_ensure,
    uid      => '51',
    comment  => 'ZFS Automatic Snapshots role',
    gid      => $client_groupname,
    shell    => $client_shell,
    home     => $client_homedir,
    password => '*NP*',
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

  file { '/etc/sudoers.d/15_zfsautosnap_client':
    ensure  => 'file',
    content => "${client_username} ALL = NOPASSWD: /sbin/zfs,/sbin/zpool
",
  }
  # file { '/usr/local/sbin/checkzfssnaplock':
  #   ensure  => 'present',
  #   source  => 'puppet:///modules/zfsautosnap/checkzfssnaplock',
  #   owner   => 'root',
  #   group   => 'sys',
  #   mode    => '0755',
  #   require => File['/usr/local/sbin'],
  # }

  # file { '/usr/local/sbin/clearzfssnaplock':
  #   ensure  => 'present',
  #   source  => 'puppet:///modules/zfsautosnap/clearzfssnaplock',
  #   owner   => 'root',
  #   group   => 'sys',
  #   mode    => '0755',
  #   require => File['/usr/local/sbin'],
  # }

  # cron { 'zfsautosnap daily lock checker':
  #   ensure  => 'present',
  #   user    => 'root',
  #   minute  => 45,
  #   hour    => 23,
  #   command => join([
  #     '/usr/local/sbin/checkzfssnaplock > /dev/null',
  #     '[ $? = 2 ] && /usr/local/sbin/clearzfssnaplock',
  #   ],'; '),
  #   require => [
  #     File['/usr/local/sbin/checkzfssnaplock'],
  #     File['/usr/local/sbin/clearzfssnaplock']
  #   ],
  # }

  # file { '/usr/local/sbin/snaphourlykiller':
  #   ensure  => 'present',
  #   source  => 'puppet:///modules/zfsautosnap/snaphourlykiller',
  #   owner   => 'root',
  #   group   => 'sys',
  #   mode    => '0755',
  #   require => File['/usr/local/sbin'],
  # } ->
  # cron { 'snaphourlykiller':
  #   ensure  => 'present',
  #   command => '/usr/local/sbin/snaphourlykiller',
  #   user    => 'root',
  #   minute  => 15,
  # }

  # svcprop { 'zfssnap daily type':
  #   fmri     => "${basefmri}:daily",
  #   property => 'zfs/backup',
  #   value    => 'incremental_mbuffered',
  #   require  => Package['IGPPzfsautosnap'],
  # }

  # svcprop { 'zfssnap daily host':
  #   fmri     => "${basefmri}:daily",
  #   property => 'zfs/backup-host',
  #   value    => $target_hostname,
  #   require  => Package['IGPPzfsautosnap'],
  # }

  # svcprop { 'zfssnap daily zpool':
  #   fmri     => "${basefmri}:daily",
  #   property => 'zfs/backup-zpool',
  #   value    => $target_pool,
  #   require  => Package['IGPPzfsautosnap'],
  # }

  # svcprop { 'zfssnap daily user':
  #   fmri     => "${basefmri}:daily",
  #   property => 'zfs/backup-user',
  #   value    => $target_username,
  #   require  => Package['IGPPzfsautosnap'],
  # }

  # service { "${basefmri}:daily" :
  #   enable  => $enable_daily,
  #   require => Package['IGPPzfsautosnap'],
  # } ->
  # svcprop { 'zfssnap daily verbose':
  #   fmri     => "${basefmri}:daily",
  #   property => 'zfs/verbose',
  #   value    => $verbose_daily_real,
  # }
  # service { "${basefmri}:hourly" :
  #   enable  => $enable_hourly,
  #   require => Package['IGPPzfsautosnap'],
  # } ->
  # svcprop { 'zfssnap hourly verbose':
  #   fmri     => "${basefmri}:hourly",
  #   property => 'zfs/verbose',
  #   value    => $verbose_hourly_real,
  # }
  # service { "${basefmri}:monthly" :
  #   enable  => false,
  #   require => Package['IGPPzfsautosnap'],
  # }
  # service { "${basefmri}:weekly" :
  #   enable  => false,
  #   require => Package['IGPPzfsautosnap'],
  # }
  # service { "${basefmri}:frequent" :
  #   enable  => false,
  #   require => Package['IGPPzfsautosnap'],
  # }
  # service { "${basefmri}:event" :
  #   enable  => false,
  #   require => Package['IGPPzfsautosnap'],
  # }

}
