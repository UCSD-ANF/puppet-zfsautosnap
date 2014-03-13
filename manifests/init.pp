class zfsautosnap(
  $recipient = 'root',
) {
  include stdlib

  # validate OS
  validate_re($::osfamily, '^Solaris$', "Unsupported OSFamily ${::osfamily}")

  mailalias { 'zfssnap': recipient => $recipient }

  package { 'mbuffer':
    provider => 'pkgutil',
    ensure   => 'installed',
  }

  if $::operatingsystemrelease == "5.10" {
    # install ksh package from CSW and symlink it to /usr/bin/ksh93
    package { 'ksh':
      provider => 'pkgutil',
      ensure   => 'installed',
    }

    file { '/usr/bin/ksh93':
      ensure  => 'link',
      target  => '/opt/csw/bin/ksh',
      require => Package['ksh'],
    }
  }
}
