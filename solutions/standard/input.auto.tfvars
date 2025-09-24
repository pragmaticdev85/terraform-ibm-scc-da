# IBM Cloud credentials
ibmcloud_api_key      = ""
iaas_classic_username = "dummy_username"
iaas_classic_api_key  = "dummy_apikey"

# Region and zone
region = "us-south"
zone   = "us-south"

# PowerVS instance parameters
prefix                     = ""
pi_existing_workspace_guid = "dummy_workspace_guid"
pi_ssh_public_key_name     = "dummy_ssh_key_name"
ssh_private_key            = <<-EOF
-----BEGIN RSA PRIVATE KEY-----

-----END RSA PRIVATE KEY-----
EOF

pi_rhel_management_server_type = "s922"
pi_rhel_image_name             = "dummy_rhel_image_name"
pi_aix_image_name              = "dummy_aix_image_name"
pi_aix_instance = {
  memory_size       = 8
  number_processors = 1
  cpu_proc_type     = "shared"
  server_type       = "s922"
  pin_policy        = "hard"
  health_status     = "OK"
}

pi_networks = [
  {
    name = ""
    id   = ""
  },
  {
    name = ""
    id   = ""
  }
]

# Optional tags
pi_user_tags = ["Tag-001","Tag-002"]

# Oracle installation storage configuration
pi_boot_volume = {
  name  = "exboot"
  size  = "40"
  count = "1"
  tier  = "tier1"
}

pi_oravg_volume = {
  name  = "oravg"
  size  = "100"
  count = "1"
  tier  = "tier1"
}

pi_data_volume = {
  name  = "DATA"
  size  = "20"
  count = "1"
  tier  = "tier1"
}

# Oracle installation and configuration
bastion_host_ip = "203.0.113.10"
ora_nfs_device  = "dummy_nfs_mount_directory"
database_sw     = "dummy_database_software_file_path_in_COS"
grid_sw         = "dummy_grid_software_file_path_in_COS"
apply_ru        = false
ru_file         = "dummy_ru_file_path_in_COS"
opatch_file     = "dummy_opatch_file_path_in_COS"
ora_sid         = ""
