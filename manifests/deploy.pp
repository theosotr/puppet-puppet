class puppet::deploy($frequency = 6, $interval_in_minutes = 60) {

  # Since 3aefec78893778f020759f947659e0f2bf30d776 we have
  # librarian-puppet support. See http://librarian-puppet.com/
  package { 'librarian-puppet':
    ensure   => present,
    provider => gem,
  }

  file { '/etc/puppet/environments':
    ensure => directory,
    mode   => 0755,
    owner  => 'root',
    group  => 'root',
    before => Class['puppet::server'],
  }

  file { "/usr/local/bin/puppet_deploy.rb":
    owner   => root,
    group   => root,
    mode    => 0750,
    source  => "puppet:///modules/puppet/puppet_deploy.rb",
  }

  cron { "Puppet: puppet_deploy.rb":
    user    => root,
    command => '/usr/local/bin/puppet_deploy.rb 1>/dev/null 2>/dev/null',
    minute  => interval($frequency, $interval_in_minutes),
    require => File["/usr/local/bin/puppet_deploy.rb"];
  }

  mcollective::plugin {'agent/deploy': has_ddl => true, module => 'puppet' }
}
