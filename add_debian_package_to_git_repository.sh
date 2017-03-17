#!/usr/bin/env bash
set -u
set -e

./build_debian_package.sh
vagrant up
vagrant ssh -c 'cd project/reprepro && reprepro --ask-passphrase includedeb general ../target/icinga2-slack-notifications_*_all.deb'
