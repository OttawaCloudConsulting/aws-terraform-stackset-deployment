s3_kms_key = {
    alias = "aws/s3",
    arn   = "arn:aws:kms:ca-central-1:296150522398:key/9e788857-ff51-4e51-95cb-c2be47d36ed7"
}

# log_bucket = {
#     name  = string,
#     id    = string
# }

standard_tags = {
    owner           = "firstname.lastname@emaildomain.com",
    classification  = "unclassified",
    solution        = "my-stackset-tool"
    deployment      = "terraform",
    deploy-date     = "2021-03-08",
    category        = "automation"
}



department = {
    lowercase   = "myco-aws",
    uppercase   = "MYCO-AWS"
}

codepipeline_project_variables = {
    projectname       = "my-cool-stackset-tool",
    projectnameshort  = "cooltool",
    stacksetname      = "my-cool-tool",
    templatepath      = "00-stackset.yml",
    pipelineiampolicy = ["arn:aws:iam::aws:policy/AdministratorAccess"],
    artifactzip       = "my-cool-tool.zip"
    regions           = "ca-central-1,us-east-1"
}

codepipeline_project_capabilities = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM,CAPABILITY_NAMED_IAM"

provider_variables = {
    region      = "ca-central-1",
    allowed_account_ids = ["1234567890"]
    access_key  = "",
    secret_key  = "",
    token       = ""
}