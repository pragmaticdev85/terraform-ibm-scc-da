#############################
# Create Workspace + Subnet
# Create RHEL VM
# Create AIX VM
# Deploy Oracle
#############################

# Create Workspace + Subnet

# Create RHEL Management VM

locals {
  nfs_mount = "/nfs"
}
module "pi_instance_rhel" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "2.7.0"

  pi_workspace_guid       = var.pi_existing_workspace_guid
  pi_ssh_public_key_name  = var.pi_ssh_public_key_name
  pi_image_id             = var.pi_rhel_image_name
  pi_networks             = var.pi_networks
  pi_instance_name        = "${var.prefix}-management-rhel"
  pi_memory_size          = "8"
  pi_number_of_processors = "1"
  pi_server_type          = var.pi_rhel_management_server_type
  pi_cpu_proc_type        = "shared"
  pi_storage_config = [{
    "name" : "nfs",
    "size" : "50",
    "count" : "1",
    "tier" : "tier3"
    "mount" : local.nfs_mount
  }]

}

# Create AIX VM for Oracle database
module "pi_instance_aix" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "2.7.0"

  pi_workspace_guid          = var.pi_existing_workspace_guid
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_aix_image_name
  pi_networks                = var.pi_networks
  pi_instance_name           = "${var.prefix}-oracle-aix"
  pi_pin_policy              = var.pi_aix_instance.pin_policy
  pi_server_type             = var.pi_aix_instance.server_type
  pi_number_of_processors    = var.pi_aix_instance.number_processors
  pi_memory_size             = var.pi_aix_instance.memory_size
  pi_cpu_proc_type           = var.pi_aix_instance.cpu_proc_type
  pi_boot_image_storage_tier = "tier1"
  pi_user_tags               = var.pi_user_tags
  pi_storage_config          = [var.pi_boot_volume, var.pi_oravg_volume, var.pi_data_volume]

}

###########################################################
# Ansible Host setup and configure as Proxy, NTP and DNS
###########################################################

locals {
  network_services_config = {
    squid = {
      "enable"     = true
      "squid_port" = "3128"
    }
    dns = {
      "enable" = true
      "dns_servers" : "161.26.0.7; 161.26.0.8; 9.9.9.9;"
    }
    ntp = {
      "enable" = true
    }

  }

}

module "pi_instance_rhel_init" {
  source     = "../../modules/ansible"
  depends_on = [module.pi_instance_rhel]

  bastion_host_ip        = var.bastion_host_ip
  ansible_host_or_ip     = module.pi_instance_rhel.pi_instance_primary_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = true

  src_script_template_name = "configure-rhel-management/ansible_exec.sh.tftpl"
  dst_script_file_name     = "configure-rhel-management.sh"

  src_playbook_template_name = "configure-rhel-management/playbook-configure-rhel-management.yml.tftpl"
  dst_playbook_file_name     = "configure-rhel-management-playbook.yml"
  playbook_template_vars     = { "server_config" : jsonencode(local.network_services_config), "pi_storage_config" : jsonencode(module.pi_instance_rhel.pi_storage_configuration), "nfs_config" : jsonencode({ "enable" : true, "directories" : [local.nfs_mount] }) }

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "configure-rhel-management-inventory"
  inventory_template_vars     = { "host_or_ip" : module.pi_instance_rhel.pi_instance_primary_ip }
}

###########################################################
# AIX Initialization
###########################################################

locals {
  playbook_aix_init_vars = {
    PROXY_IP_PORT  = "${module.pi_instance_rhel.pi_instance_primary_ip}:3128"
    NO_PROXY       = "TODO"
    ORA_NFS_HOST   = module.pi_instance_aix.pi_instance_primary_ip
    ORA_NFS_DEVICE = local.nfs_mount #TODO
  }

}

module "pi_instance_aix_init" {
  source     = "../../modules/ansible"
  depends_on = [module.pi_instance_rhel_init]

  bastion_host_ip        = var.bastion_host_ip
  ansible_host_or_ip     = module.pi_instance_rhel.pi_instance_primary_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "aix-init/ansible_exec.sh.tftpl"
  dst_script_file_name     = "aix_init.sh"

  src_playbook_template_name = "aix-init/playbook-aix-init.yml.tftpl"
  dst_playbook_file_name     = "aix-init-playbook.yml"
  playbook_template_vars     = local.playbook_aix_init_vars

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "aix-init-inventory"
  inventory_template_vars     = { "host_or_ip" : module.pi_instance_aix.pi_instance_primary_ip }

}


###########################################################
# Oracle GRID Installation on AIX
###########################################################

locals {
  playbook_oracle_grid_install_vars = {
    ORA_NFS_HOST   = module.pi_instance_aix.pi_instance_primary_ip
    ORA_NFS_DEVICE = var.ora_nfs_device #TODO
    DATABASE_SW    = var.database_sw    #TODO
    GRID_SW        = var.grid_sw        #TODO
    APPLY_RU       = var.apply_ru       #TODO
    RU_FILE        = var.ru_file        #TODO
    OPATCH_FILE    = var.opatch_file    #TODO
    ORA_SID        = var.ora_sid        #TODO
  }

}
module "oracle_grid_install" {
  source     = "../../modules/ansible"
  depends_on = [module.pi_instance_aix_init]

  bastion_host_ip        = var.bastion_host_ip
  ansible_host_or_ip     = module.pi_instance_rhel.pi_instance_primary_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "oracle-grid-install/ansible_exec.sh.tftpl"
  dst_script_file_name     = "oracle_grid_install.sh"

  src_playbook_template_name = "oracle-grid-install/playbook-oracle-grid-install.yml.tftpl"
  dst_playbook_file_name     = "oracle-grid-install-playbook.yml"
  playbook_template_vars     = local.playbook_oracle_grid_install_vars

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "oracle-grid-install-inventory"
  inventory_template_vars     = { "host_or_ip" : module.pi_instance_aix.pi_instance_primary_ip }
}
