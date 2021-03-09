s3_kms_key = {
    alias = "myKMSCMKkey",
    arn   = "arn:aws:kms:ca-central-1:123456789012:key/a12bf3c4-5678-9d0e-123f-45a6789b0123"
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
}

codepipeline_project_capabilities = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM,CAPABILITY_NAMED_IAM"

provider_variables = {
    region      = "ca-central-1",
    access_key  = "",
    secret_key  = "",
    token       = ""
}