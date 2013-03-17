class cinder::keystone::auth (
  $password,
  $enabled             = true,
  $auth_name          = 'cinder',
  $email              = 'cinder@localhost',
  $tenant             = 'services',
  $configure_endpoint = true,
  $service_type       = 'volume',
  $public_address     = '127.0.0.1',
  $admin_address      = '127.0.0.1',
  $internal_address   = '127.0.0.1',
  $port               = '8776',
  $volume_version     = 'v1',
  $region             = 'RegionOne',
  $public_protocol    = 'http'
) {
  if $enabled {
    $ensure = present
  } else {
    $ensure = absent
  }

  Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'cinder-api' |>

  keystone_user { $auth_name:
    ensure   => $ensure,
    password => $password,
    email    => $email,
    tenant   => $tenant,
  }
  keystone_user_role { "${auth_name}@${tenant}":
    ensure  => $ensure,
    roles   => 'admin',
  }
  keystone_service { $auth_name:
    ensure      => $ensure,
    type        => $service_type,
    description => "Cinder Service",
  }

  if $configure_endpoint {
    keystone_endpoint { $auth_name:
      ensure       => $ensure,
      region       => $region,
      public_url   => "${public_protocol}://${public_address}:${port}/${volume_version}/%(tenant_id)s",
      admin_url    => "http://${admin_address}:${port}/${volume_version}/%(tenant_id)s",
      internal_url => "http://${internal_address}:${port}/${volume_version}/%(tenant_id)s",
    }
  }
}
