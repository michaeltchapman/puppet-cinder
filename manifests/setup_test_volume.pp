class cinder::setup_test_volume(
  $volume_name     = 'cinder.loopback',
  $volume_group    = 'cinder-volumes',
  $size            = '1G',
  $extents         = '255', #255 for 1G, 511 for 2G
  $loopback_device = '/dev/loop0',
  $mount_point     = '/cinder-volumes',
) {

  Exec {
    cwd => '/var/tmp/',
  }

  exec { "/bin/dd if=/dev/zero of=${volume_name} bs=1 count=0 seek=${size}":
    unless => "/sbin/vgdisplay ${volume_name}"
  } ~>

  exec { "/sbin/losetup ${loopback_device} ${volume_name}":
    refreshonly => true,
  } ~>

  exec { "/sbin/pvcreate ${loopback_device}":
    refreshonly => true,
  } ~>

  exec { "/sbin/vgcreate ${volume_name} ${loopback_device}":
    refreshonly => true,
  } ~>
  exec { "/sbin/lvcreate -l ${extents} -n ${volume_group} ${volume_name}":
    unless => "/sbin/lvdisplay ${volume_group}"
  } ~>
  exec { "/sbin/mkfs.ext4 /dev/${volume_name}/${volume_group && mount /dev/${volume_name}/${volume_group ":
    refreshonly => true, 
  } ~>
  exec { "/bin/cat \"/dev/cinder.loopback/cinder-volumes /cinder-volumes ext4 defaults 0 0\" >> /etc/fstab":
    refreshonly => true,
  }

}

