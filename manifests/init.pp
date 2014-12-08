# Bring zfsautosnap up-to-parity
class zfsautosnap(
  $recipient = 'root',
) {
  # validate OS
  validate_re($::osfamily, '^Solaris$', "Unsupported OSFamily ${::osfamily}")

  mailalias { 'zfssnap': recipient => $recipient }

  $provider = $::osfamily ? {
    'RedHat'  => undef,
    'Solaris' => $::operatingsystemrelease ? {
      '5.10'  => 'pkgutil',
      default => undef,
    },
  }
  $paramiko_name = $::osfamily ? {
    'RedHat'  => 'python-paramiko',
    'Solaris' => 'py_paramiko',
  }
  if !defined(Package['mbuffer']) {
    package { 'mbuffer': ensure => 'installed', provider => $provider }
  }
  if !defined(Package[$paramiko_name]) {
    package { $paramiko_name: ensure => 'installed', provider => $provider }
  }

  if $::operatingsystemrelease == '5.10' {
    # install ksh package from CSW and symlink it to /usr/bin/ksh93
    # ... if OpenCSW supported it.
    #package { 'ksh':
    #  provider => 'pkgutil',
    #  ensure   => 'installed',
    #  before   => File['/usr/bin/ksh93'],
    #}

    file { '/usr/bin/ksh93':
      ensure => 'link',
      target => '/opt/csw/bin/ksh',
    }
  }
}
