variable "provider_variables" {
  type          = object({
    region      = string,
    access_key  = string,
    secret_key  = string,
    token       = string,
    allowed_account_ids = list(string)
  })
}

variable "s3_kms_key" {
  type          = object({
    alias = string
    arn   = string
  })
  description   = "KMS CMK Key for S3 - variable must include .arn attribute"
}

#variable "log_bucket" {
#  type          = object({
#    name  = string 
#    id    = string
#  })
#  description   = "S3 Logging Bucket, including ID"
#}

variable "standard_tags" {
  type  = object({
    owner           = string
    classification  = string
    solution        = string
    deployment      = string
    deploy-date     = string
    category        = string
  })
  description = "Standard Tags"
}

variable "department" {
  type = object({
    lowercase   = string
    uppercase   = string
  })
  description = "Name as acronym component for parameterization"
}

variable "codepipeline_project_variables" {
  type = object({
    projectname       = string
    projectnameshort  = string
    stacksetname      = string
    templatepath      = string
    pipelineiampolicy = list(string)
    artifactzip       = string
    regions           = string
    stacksetparams    = string
  })
  description = "Set of variables specific to the CodePipeline Project"
}

variable "codepipeline_project_capabilities" {
type  = string
}