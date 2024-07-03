variable "sshkey" {
  description = "SSH key to use with EC2 host"
}

variable "hosts" {
  description = "Number of hosts to create"
  type = list(string)
  default = []
}

variable "disks" {
  description = "DO NOT EXCEED 4 DISKS"
  type = list(string)
  default = ["h", "i"] # Full disks: ["h", "i", "j", "k"]
}
