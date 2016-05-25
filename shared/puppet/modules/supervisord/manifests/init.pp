class supervisord (
    $runas = 'root',
    $minprocs = 3
) {
    service {
        'supervisord':
            enable  => true;
    }

    file {
        '/var/log/supervisor':
            ensure  => directory,
            owner   => 'w3moodle',
            group   => 'pkg',
            mode    => 0755;

        '/etc/supervisord.d':
            ensure  => directory,
            mode    => 0755;

        '/etc/supervisord.conf':
            ensure  => present,
            content => template('supervisord/supervisord.conf.erb'),
            mode    => 0644;
    }

    define worker ($workername = $title, $command, $runas = 'w3moodle', $priority = 1024, $numprocs = 1, $startsecs = 1) {
        file {
            "/etc/supervisord.d/worker-$workername.conf":
                ensure  => present,
                content => template('supervisord/worker.conf.erb'),
                mode    => 0644;
        }
    }
}
