variable "region" {
  description = "La région AWS"
  default     = "eu-west-3"
}

variable "cluster_name" {
  description = "Nom du cluster EKS"
  default     = "info-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs des sous-réseaux publics"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "node_instance_type" {
  description = "Type d'instance pour les nodes"
  default     = "t3.micro"
}

variable "desired_capacity" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "min_size" {
  default = 1
}
