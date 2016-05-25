class webfarm::base {
    file {
        ["/var/www", "/var/www/vhosts"]:
            ensure => directory;
    }
}
