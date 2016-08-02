node 'default'
{
    include moodle::base
    include supervisord

    service {
        ['nginx', 'crond', 'php56-php-fpm']:
            enable => true;
    }

    file {
        '/etc/nginx/conf.d/default.conf':
            ensure => absent;

        '/etc/nginx/conf.d/moodle-dev.kent.ac.uk.conf':
            ensure => present,
            source => 'puppet:///modules/webfarm/moodle-dev.kent.ac.uk.conf';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/current':
            ensure => link,
            target => '/data/current';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/future':
            ensure => link,
            target => '/data/future';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/cla':
            ensure => link,
            target => '/data/cla/public';

        '/var/www/vhosts/moodle-dev.kent.ac.uk/public/_sp':
            ensure => link,
            target => '/var/www/vhosts/moodle-dev.kent.ac.uk/sp/simplesamlphp/www';

        '/opt/remi/php56/root/etc/php-fpm.d/www.conf':
            ensure => absent;

        '/opt/remi/php56/root/etc/php-fpm.d/moodle-dev.kent.ac.uk.conf':
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
            command => '/usr/bin/php /var/www/vhosts/moodle-dev.kent.ac.uk/public/current/admin/tool/adhoc/queue/beanstalk/cli/worker.php',
            startsecs => 5;

        'future':
            command => '/usr/bin/php /var/www/vhosts/moodle-dev.kent.ac.uk/public/future/admin/tool/adhoc/queue/beanstalk/cli/worker.php',
            startsecs => 5;
    }
}
