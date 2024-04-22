variable "access_key" {
  type = string
  sensitive = false
}

variable "secret_key" {
  type = string
  sensitive = true
}


variable "instance_tag2" {
  description = "Tag given to each deployed Instance"
  type = list(string)
  default = ["first", "second", "third"]
}
