variable "ibmcloud_api_key" {
  description = "API Key of IBM Cloud Account."
  type        = string
  sensitive   = true
}

variable "iaas_classic_username" {
  description = "IBM Cloud Classic IaaS username. Remove after testing. Todo"
  type        = string
}

variable "iaas_classic_api_key" {
  description = "IBM Cloud Classic IaaS API key. Remove after testing. Todo"
  type        = string
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The IBM Cloud region to deploy resources."
}

variable "zone" {
  description = "The IBM Cloud zone to deploy the PowerVS instance."
  type        = string
}

#####################################################
# Parameters IBM Cloud PowerVS Instance
#####################################################
variable "prefix" {
  description = "A unique identifier for resources. Must contain only lowercase letters, numbers, and - characters. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
}

variable "pi_existing_workspace_guid" {
  description = "Existing Power Virtual Server Workspace GUID."
  type        = string
}

variable "pi_ssh_public_key_name" {
  description = "Name of the SSH key pair to associate with the instance"
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'pi_ssh_public_key_name' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "pi_rhel_management_server_type" {
  description = "Server type for the management instance."
  type        = string
}

variable "pi_rhel_image_name" {
  description = "Name of the IBM PowerVS RHEL boot image to use for provisioning the instance. Must reference a valid RHEL image."
  type        = string
}

variable "pi_aix_image_name" {
  description = "Name of the IBM PowerVS AIX boot image used to deploy and host Oracle Database Appliance."
  type        = string
}

variable "pi_aix_instance" {
  description = "Configuration settings for the IBM PowerVS AIX instance where Oracle will be installed. Includes memory size, number of processors, processor type, and system type."

  type = object({
    memory_size       = number # Memory size in GB
    number_processors = number # Number of virtual processors
    cpu_proc_type     = string # Processor type: shared, capped, or dedicated
    server_type       = string # System type (e.g., s922, e980)
    pin_policy        = string # Pin policy (e.g., hard, soft)
    health_status     = string # Health status (e.g., OK, Warning, Critical)
  })
  default = {
    "memory_size" : "8",
    "number_processors" : "1",
    "cpu_proc_type" : "shared",
    "server_type" : "s922",
    "pin_policy" : "hard",
    "health_status" : "OK"
  }
}

variable "pi_networks" {
  description = "Existing list of private subnet ids to be attached to an instance. The first element will become the primary interface. Run 'ibmcloud pi networks' to list available private subnets."
  type = list(object({
    name = string
    id   = string
  }))
  default = []
}

#####################################################
# Oracle Storage Configuration
#####################################################

# 1. rootvg
variable "pi_boot_volume" {
  description = "Boot volume configuration"
  type = object({
    name  = string
    size  = string
    count = string
    tier  = string
  })
  default = {
    "name" : "exboot",
    "size" : "40",
    "count" : "1",
    "tier" : "tier1"
  }
}

# 2. oravg
variable "pi_oravg_volume" {
  description = "ORAVG volume configuration"
  type = object({
    name  = string
    size  = string
    count = string
    tier  = string
  })
  default = {
    "name" : "oravg",
    "size" : "100",
    "count" : "1",
    "tier" : "tier1"
  }
}

# 3. DATA diskgroup
variable "pi_data_volume" {
  description = "Disk configuration for ASM"
  type = object({
    name  = string
    size  = string
    count = string
    tier  = string
  })
  default = {
    "name" : "DATA",
    "size" : "20",
    "count" : "1",
    "tier" : "tier1"
  }
}


############################################
# Optional IBM PowerVS Instance Parameters
############################################
variable "pi_user_tags" {
  description = "List of Tag names for IBM Cloud PowerVS instance and volumes. Can be set to null."
  type        = list(string)
  default     = null
}


#####################################################
# Parameters Oracle Installation and Configuration
#####################################################

variable "bastion_host_ip" {
  description = "Jump/Bastion server public IP address to reach the ansible host which has private IP."
  type        = string
}

variable "ora_nfs_device" {
  description = "NFS Mount directory. TODO"
  type        = string
}

variable "database_sw" {
  description = "Location of the database software file to be applied. TODO"
  type        = string
}

variable "grid_sw" {
  description = "Location of the grid software file to be applied. TODO"
  type        = string
}

variable "apply_ru" {
  description = "If set to true, ansible play will be executed to preform oracle/grid patch. TODO"
  type        = bool
}

variable "ru_file" {
  description = "Location of the opatch file to be applied. TODO"
  type        = string
  default     = "/repos/binaries/RU19.27/p37641958_190000_AIX64-5L.zip" # remove once ansible logic is fixed
}

variable "opatch_file" {
  description = "Location of the opatch file to be applied."
  type        = string
}

variable "ora_sid" {
  description = "Name for the oracle database DB SID."
  type        = string
}
