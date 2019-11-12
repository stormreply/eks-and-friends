########### set your favorite region ###########
variable "region" {
  default = "eu-central-1"
}

variable "cluster_version" {
  default = "1.13"
}


variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    ########### change to your account id ###########
    "753769914557",
  ]
}

########### add your name or email or nickname ###########
variable "yourname" {
  description = "Your name without spaces"
  default = "max"
}

########### give your cluster a name ###########
variable "clustername" {
  description = "Your cluster name without spaces"
  default = "max_k8s"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      ########## add the ARN for your role ###########
      rolearn  = "arn:aws:iam::753769914557:role/team.bu1.mkoerbaecher"
      username = "team.bu1.mkoerbaecher"
      groups   = ["system:masters"]
   },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      ########### add the ARN for additional user who should have access to your cluster ###########
      userarn  = "arn:aws:iam::753769914557:user/max"
      username = "max"
      groups   = ["system:masters"]
    },
    {
      ########### add the ARN for additional user who should have access to your cluster ###########
      userarn  = "arn:aws:iam::753769914557:user/christoph"
      username = "christoph"
      groups   = ["system:masters"]
    },
  ]
}

