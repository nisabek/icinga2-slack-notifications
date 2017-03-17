#!/usr/bin/env bash
set -u
set -e

VERSION='1.0.2'
DEBUG='false'

clean() {
    mkdir -p target
    rm -rf target/*
}

build_package() {
    cd target
    fpm \
        --force \
        --output-type deb \
        --input-type dir \
        --version "${VERSION}" \
        --deb-no-default-config-files \
        --deb-user 'root' \
        --deb-group 'nagios' \
        --depends 'curl, icinga2' \
        --architecture 'all' \
        --name 'icinga2-slack-notifications' \
        --description 'Icinga2 notification integration with slack' \
        --vendor 'https://envimate.com/' \
        --maintainer 'Nune Isabekyan <nisabek@gmail.com>, Richard Hauswald <richard.hauswald@gmail.com>' \
        --url 'https://github.com/nisabek/icinga2-slack-notifications' \
        --license 'Apache License Version 2.0, January 2004' \
        --category 'universe/admin' \
        --deb-priority 'extra' \
        --deb-field 'Bugs: https://github.com/nisabek/icinga2-slack-notifications/issues' \
        ../src/slack-notifications=/etc/icinga2/conf.d

    if [ "${DEBUG}" = "true" ]; then
        mkdir debug
        cp "icinga2-slack-notifications_${VERSION}_all.deb" debug/
        cd debug
        tar -xzf "icinga2-slack-notifications_${VERSION}_all.deb"
        mkdir control
        mv control.tar.gz control/
        cd control
        tar -xzf control.tar.gz
        cd ..
        cd ..
    fi

    cd ..
}

clean
build_package
