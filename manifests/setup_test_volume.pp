class cinder::setup_test_volume(
  $volume_file     = '/var/tmp/cinder.loopback',
  $volume_name     = 'cinder.loopback',
  $volume_group    = 'cinder-volumes',
  $size            = '1G',
  $extents         = '255', #255 for 1G, 511 for 2G
  $loopback_device = '/dev/loop0',
  $mount_point     = '/cinder-volumes',
) {

  file { "/cinder-volumes":
    ensure => directory,
    owner  => 'root',
  }
  file_line { 'fstab_volume':
    path => '/etc/fstab',
    line => '/dev/cinder.loopback/cinder-volumes /cinder-volumes ext4 defaults 0 0',
  }

  exec { "/bin/dd if=/dev/zero of=${volume_file} bs=1 count=0 seek=${size}":
    creates => "${volume_file}",
    unless => "/sbin/vgdisplay ${volume_name}",
  } ~>
  exec { "/sbin/losetup ${loopback_device} ${volume_file}":
    subscribe   => File["/cinder-volumes"],
  } ~>
  exec { "/sbin/pvcreate ${loopback_device}": } ~>
  exec { "/sbin/vgcreate ${volume_name} ${loopback_device}": } ~>
  exec { "/sbin/lvcreate -l ${extents} -n ${volume_group} ${volume_name}":
    unless => "/sbin/lvdisplay ${volume_group}",
  } ~>
  exec { "/sbin/mkfs.ext4 /dev/${volume_name}/${volume_group}": } ~>
  exec { "/bin/mount /dev/${volume_name}/${volume_group} ${mount_point}":
    require     => File['/cinder-volumes'],
  }
}
