#!/usr/bin/bash

yum install ${packages} -y
echo "${nameserver}" >> /etc/resolv.conf

cat << EOF > /tmp/setup.pp
package { 'httpd':
  ensure => installed
}

service { 'httpd':
  ensure  => running,
  require => [
    Package['httpd'],
  ],
}
EOF

puppet apply /tmp/setup.pp
