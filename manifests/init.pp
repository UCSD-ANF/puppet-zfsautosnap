class zfsautosnap(
  $recipient = 'root',
) {
  include stdlib

  # validate OS
  validate_re($::osfamily, '^Solaris$', "Unsupported OSFamily ${::osfamily}")

  mailalias { 'zfssnap': recipient => $recipient }

  $paramiko_name = $::osfamily ? {
    'Solaris' => 'py_paramiko',
    'RedHat'  => 'python-paramiko',
  }
  package { [
    'mbuffer',
    $paramiko_name,
  ]:
    provider => 'pkgutil',
    ensure   => 'installed',
  }

  if $::operatingsystemrelease == "5.10" {
    # install ksh package from CSW and symlink it to /usr/bin/ksh93
    # ... if OpenCSW supported it.
    #package { 'ksh':
    #  provider => 'pkgutil',
    #  ensure   => 'installed',
    #}

    file { '/usr/bin/ksh93':
      ensure  => 'link',
      target  => '/opt/csw/bin/ksh',
      #require => Package['ksh'],
    }
  }
}
