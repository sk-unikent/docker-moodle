node 'default'
{
    include moodle::base

    file {
        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/testing':
            ensure => link,
            target => '/data';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/writable/data/testing':
            ensure => directory,
            require => File['/var/www/vhosts/moodle-dev.kent.ac.uk/writable/data'];
    }
}
