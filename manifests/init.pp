class zfsautosnap {
  # validate OS
  if $::osfamily != 'Solaris' {
    fail("Unsupported OSFamily $::osfamily")
  }

  # install ksh package from CSW and symlink it to /usr/bin/ksh93
  package { 'ksh':
    provider => 'pkgutil',
    ensure   => 'installed',
  }

  package { 'mbuffer':
    provider => 'pkgutil',
    ensure   => 'installed',
  }

  file { '/usr/bin/ksh93':
    ensure  => 'link',
    target  => '/opt/csw/bin/ksh',
    require => Package['ksh'],
  }
}
