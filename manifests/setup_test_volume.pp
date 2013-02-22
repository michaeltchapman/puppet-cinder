class cinder::setup_test_volume() {
  file { "/cinder-volumes":
    ensure => directory,
    owner  => 'root',
  }
  file_line { 'fstab_volume':
    path => '/etc/fstab',
    line => '/dev/cinder-volumes/cinder-volumes /cinder-volumes ext4 defaults 0 0',
  }
  exec { "/bin/dd if=/dev/zero of=/var/tmp/cinder.loopback bs=1 count=0 seek=1G":
    creates => "/var/tmp/cinder.loopback",
  } ~>
  exec { "/sbin/losetup /dev/loop0 /var/tmp/cinder.loopback":
    unless => "/sbin/losetup /dev/loop0",
  } ~>
  exec { "/sbin/pvcreate /dev/loop0": 
    unless => "/sbin/pvdisplay /dev/loop0",
  } ~>
  exec { "/sbin/vgcreate cinder-volumes /dev/loop0": 
    unless => "/sbin/vgdisplay cinder-volumes",
  } ~>
  exec { "/sbin/lvcreate -l 255 -n cinder-volumes cinder-volumes":
  } ~>
  exec { "/sbin/mkfs.ext4 /dev/cinder-volumes/cinder-volumes": 
    refreshonly => true,
  } ~>
  exec { "/bin/mount /dev/cinder-volumes/cinder-volumes /cinder-volumes":
    unless => "/bin/df -T | /bin/grep cinder",
    require     => File['/cinder-volumes'],
  }
}
