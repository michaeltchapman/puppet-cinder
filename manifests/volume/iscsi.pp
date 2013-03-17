#
class cinder::volume::iscsi (
  $iscsi_ip_address,
  $volume_group      = 'cinder-volumes',
  $iscsi_helper      = 'tgtadm',
  $state_path             = '/var/lib/cinder',
) {

  include cinder::params
  include cinder::params

  cinder_config {
    'DEFAULT/iscsi_ip_address': value => $iscsi_ip_address;
    'DEFAULT/iscsi_helper':     value => $iscsi_helper;
    'DEFAULT/volume_group':     value => $volume_group;
   }

  case $iscsi_helper {
    'tgtadm': {
      package { 'tgt':
        name   => $::cinder::params::tgt_package_name,
        ensure => present,
      }

      if($::osfamily == 'RedHat') {
        file_line { 'cinder include':
          path => '/etc/tgt/targets.conf',
          line => "include ${state_path}/volumes/*",
          match => '#?include /',
          require => Package['tgt'],
          notify => Service['tgtd'],
        }
      } elsif($::osfamily == 'Debian') {
        file{ '/etc/tgt/conf.d/cinder.conf':
          content => "include ${state_path}/volumes/*",
          require => Package['tgt'],
          notify => Service['tgtd'],
        }
      }

      service { 'tgtd':
        name    => $::cinder::params::tgt_service_name,
        ensure  => running,
        enable  => true,
        require => Class['cinder::volume'],
      }
    }

    default: {
      fail("Unsupported iscsi helper: ${iscsi_helper}.")
    }
  }

}
