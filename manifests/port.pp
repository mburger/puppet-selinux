define selinux::port (
  $context,
  $port,
  $protocol = undef
) {

  if $protocol {
    $protocol_switch="-p ${protocol} "
  } else {
    $protocol_switch=''
  }

  exec { "add_${context}_${port}":
    command => "semanage port -a -t ${context} ${protocol_switch}${port}",
    unless  => "semanage port -l|grep \"^${context}.*${protocol}.*${port}\"",
    require => Package[$::selinux::package]
  }
}
