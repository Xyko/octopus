class os {
  file {
    "/home/xyko/motd":
      ensure => file,
      source => "puppet:///modules/os/motd";
  }
}
