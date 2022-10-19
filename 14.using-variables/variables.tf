variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Current Region"
}

variable "port_list" {
    description = "List of Port to open for Web Server"
    type = list(any)
    default = ["80", "443"]
}

variable "instance_size" {
  description = "EC2 Instance Size"
    type = string
    default = "t3.micro"
}

variable "tags" {
  description = "Tags to Apply to Resources"
    type = map(any)
    default = {
      Owner= "Mustofa Kodir"
      Environment="Prod"
      Project = "Phoenix"
    }
}