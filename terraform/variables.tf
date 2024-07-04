variable "sshkey" {
  description = "SSH key to use with EC2 host"
}

variable "hosts" {
  description = "Number of hosts to create"
  type = number
  default = 2
}

variable "disks" {
  description = "DO NOT EXCEED 4 DISKS"
  type = list(string)
  default = ["h", "i", "j", "k"] # Full disks: ["h", "i", "j", "k"]
}
