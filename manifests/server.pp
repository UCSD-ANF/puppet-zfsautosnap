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
  $client_ssh_pubkey,
  $client_ssh_pubkey_type,
  $target_pool = 'zfsbackups',
  $target_username = 'zfsbackup'
) {

  # bring in common dependencies
  include zfsautosnap

  # Install client key
  ssh_authorized_key { 'zfsautosnap client key':
    type    => $client_ssh_pubkey_type,
    key     => $client_ssh_pubkey,
    user    => $target_username,
    require => User[$target_username],
  }

  # Make sure target pool exists
  zpool { $target_pool : }
}
