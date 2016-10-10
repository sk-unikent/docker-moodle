node 'default'
{
    include moodle::base
    include supervisord

    group {
        'pkg':
            ensure => 'present';
    }

    service {
        ['nginx', 'crond', 'php71-php-fpm']:
            enable => true;
    }

    file {
        '/etc/nginx/conf.d/default.conf':
            ensure => absent;

        '/etc/nginx/conf.d/moodle-dev.kent.ac.uk.conf':
            ensure => present,
            source => 'puppet:///modules/webfarm/moodle-dev.kent.ac.uk.conf';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/doc':
            ensure => link,
            target => '/data/doc';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/index.php':
            ensure => link,
            target => '/data/index.php';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/current':
            ensure => link,
            target => '/data/current';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/future':
            ensure => link,
            target => '/data/future';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/mobile':
            ensure => link,
            target => '/data/mobile/www';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/cla':
            ensure => link,
            target => '/data/cla/public';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/_sp':
            ensure => link,
            target => '/var/www/vhosts/moodle-dev.kent.ac.uk/sp/simplesamlphp/www';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/phpredmin':
            ensure => link,
            target => '/var/www/vhosts/moodle-dev.kent.ac.uk/phpredmin/public';

        '/etc/opt/remi/php71/php-fpm.d/www.conf':
            ensure => absent;

        '/etc/opt/remi/php71/php-fpm.d/moodle-dev.kent.ac.uk.conf':
            ensure => present,
            source => 'puppet:///modules/webfarm/moodle-pool.conf';
    }

    cron {
        'current-demo':
            command => '/usr/bin/php /var/www/vhosts/moodle-dev.kent.ac.uk/public/current/admin/cli/cron.php',
            user    => 'w3moodle',
            hour    => '*',
            minute  => '*';

        'future-demo':
            command => '/usr/bin/php /var/www/vhosts/moodle-dev.kent.ac.uk/public/future/admin/cli/cron.php',
            user    => 'w3moodle',
            hour    => '*',
            minute  => '*';
    }

    supervisord::worker {
        'current':
            command => '/usr/bin/php /var/www/vhosts/moodle-dev.kent.ac.uk/public/current/local/kent/cli/worker.php',
            startsecs => 5;
        'future':
            command => '/usr/bin/php /var/www/vhosts/moodle-dev.kent.ac.uk/public/future/admin/tool/adhoc/queue/redis/cli/worker.php',
            startsecs => 5;
    }
}
