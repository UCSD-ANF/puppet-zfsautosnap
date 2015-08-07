# Params:
# client_ssh_pubkey - long string containing the key part of an SSH public
#   key
# client_ssh_pubkey_type - either ssh-dss or ssh-rsa
# target_pool - top level pool name on the server where snapshots will be
#   stored
# target_username - name of the user on the server that will receive the
#   snapshots. This module won't create the user or it's .ssh directory so
#   you will have to have glue code somewhere to define the user resource.
class zfsautosnap::server (
  $client_ssh_pubkey=undef,
  $client_ssh_pubkey_type=undef,
  $target_pool = 'zfsbackups',
  $target_username = 'zfsbackup',
  $target_user_homedir = '/var/zfsbackup',
  $target_user_uid = 9029,
) {

  # bring in common dependencies
  require zfsautosnap

  $target_user_ensure = $::osfamily ? {
    'Solaris' => 'role',
    default   => 'present',
  }

  $target_user_shell = $::osfamily ? {
    'Solaris' => '/bin/pfsh',
    'FreeBSD' => '/usr/local/bin/bash',
    default   => '/bin/bash',
  }

  user { $target_username:
    ensure   => $target_user_ensure,
    uid      => $target_user_uid,
    comment  => 'ZFS Remote Backups Role',
    password => '*NP*',
    home     => $target_user_homedir,
    shell    => $target_user_shell,
  }->
  file { "${target_user_homedir}":
    ensure => 'directory',
    owner  => $target_username,
    group  => $target_username,
    mode   => 0755,
  }->
  file { "${target_user_homedir}/.ssh":
    ensure => 'directory',
    owner  => $target_username,
    group  => $target_username,
    mode   => 0755,
  }
  # Install client key
  if ($client_ssh_pubkey_type and $client_ssh_pubkey) {
    ssh_authorized_key { 'zfsautosnap client key':
      type    => $client_ssh_pubkey_type,
      key     => $client_ssh_pubkey,
      user    => $target_username,
      mode    => 0644,
      require => File["$target_user_homedir/.ssh"],
    }
  }

  file { '/etc/sudoers.d/15_zfsautosnap_target':
    ensure  => 'file',
    content => "${target_username} ALL = NOPASSWD: /sbin/zfs,/sbin/zpool
",
  }


  # # Make sure target pool exists
  # zpool { $target_pool : }
}
