class moodle::base {
    group {
        'pkg':
            ensure => 'present';
    }

    user {
        ['w3moodle', 'w3admin']:
            ensure => 'present',
            managehome => true,
            groups => ['pkg'],
            require => Group['pkg'];
    }

    file {
        '/var/www/vhosts/moodle-dev.kent.ac.uk/writable/data/shared':
            ensure => directory,
            owner => 'w3moodle',
            require => File['/var/www/vhosts/moodle-dev.kent.ac.uk/writable/data'];
    }

    class {
        'webfarm::base': ;
    }

    webfarm::base::vhost {
        'moodle-dev.kent.ac.uk': ;
    }
}
