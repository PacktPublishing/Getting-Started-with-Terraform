host { 'repository':
  ip => '10.24.45.128',
}

package { 'httpd':
  ensure => installed
}

service { 'httpd':
  ensure  => running,
  require => [
    Package['httpd'],
  ],
}
