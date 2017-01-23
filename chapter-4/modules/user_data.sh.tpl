#!/usr/bin/bash
yum install ${packages} -y
echo "${nameserver}" >> /etc/resolv.conf
