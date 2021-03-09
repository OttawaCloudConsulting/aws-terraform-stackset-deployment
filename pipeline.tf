provider "aws" {
    region      = var.provider_variables.region
    access_key  = var.provider_variables.access_key
    secret_key  = var.provider_variables.secret_key
    token       = var.provider_variables.token
}

data "aws_organizations_organization" "awsorg" {}

output "org_root_id" {
  value         = data.aws_organizations_organization.awsorg.roots[0].id
}

output "master_root_account_arn" {
  value = data.aws_organizations_organization.awsorg.master_account_arn
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

#resource "aws_iam_role" "IAMRoleCFN" {
#    path = "/"
#    name =  "${var.department.uppercase}-${var.codepipeline_project_variables.projectname}-CodePipelineCloud"
#    assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"cloudformation.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
#    managed_policy_arns = var.codepipeline_project_variables.pipelineiampolicy
#    max_session_duration = 3600
#    tags = var.standard_tags
#}

resource "aws_iam_policy" "IAMManagedPolicy" {
    name = "${var.department.uppercase}-${var.codepipeline_project_variables.projectname}-CodePipelineCFN"
    path = "/"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Condition\":{\"StringEqualsIfExists\":{\"iam:PassedToService\":[\"cloudformation.amazonaws.com\",\"elasticbeanstalk.amazonaws.com\",\"ec2.amazonaws.com\",\"ecs-tasks.amazonaws.com\"]}},\"Action\":[\"iam:PassRole\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"codecommit:CancelUploadArchive\",\"codecommit:GetBranch\",\"codecommit:GetCommit\",\"codecommit:GetUploadArchiveStatus\",\"codecommit:UploadArchive\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"codedeploy:CreateDeployment\",\"codedeploy:GetApplication\",\"codedeploy:GetApplicationRevision\",\"codedeploy:GetDeployment\",\"codedeploy:GetDeploymentConfig\",\"codedeploy:RegisterApplicationRevision\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"codestar-connections:UseConnection\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"elasticbeanstalk:*\",\"ec2:*\",\"elasticloadbalancing:*\",\"autoscaling:*\",\"cloudwatch:*\",\"s3:*\",\"sns:*\",\"cloudformation:*\",\"rds:*\",\"sqs:*\",\"ecs:*\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"lambda:InvokeFunction\",\"lambda:ListFunctions\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"opsworks:CreateDeployment\",\"opsworks:DescribeApps\",\"opsworks:DescribeCommands\",\"opsworks:DescribeDeployments\",\"opsworks:DescribeInstances\",\"opsworks:DescribeStacks\",\"opsworks:UpdateApp\",\"opsworks:UpdateStack\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"cloudformation:CreateStack\",\"cloudformation:DeleteStack\",\"cloudformation:DescribeStacks\",\"cloudformation:UpdateStack\",\"cloudformation:CreateChangeSet\",\"cloudformation:DeleteChangeSet\",\"cloudformation:DescribeChangeSet\",\"cloudformation:ExecuteChangeSet\",\"cloudformation:SetStackPolicy\",\"cloudformation:ValidateTemplate\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"codebuild:BatchGetBuilds\",\"codebuild:StartBuild\",\"codebuild:BatchGetBuildBatches\",\"codebuild:StartBuildBatch\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"devicefarm:ListProjects\",\"devicefarm:ListDevicePools\",\"devicefarm:GetRun\",\"devicefarm:GetUpload\",\"devicefarm:CreateUpload\",\"devicefarm:ScheduleRun\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"servicecatalog:ListProvisioningArtifacts\",\"servicecatalog:CreateProvisioningArtifact\",\"servicecatalog:DescribeProvisioningArtifact\",\"servicecatalog:DeleteProvisioningArtifact\",\"servicecatalog:UpdateProduct\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"cloudformation:ValidateTemplate\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"ecr:DescribeImages\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"states:DescribeExecution\",\"states:DescribeStateMachine\",\"states:StartExecution\"],\"Resource\":\"*\",\"Effect\":\"Allow\"},{\"Action\":[\"appconfig:StartDeployment\",\"appconfig:StopDeployment\",\"appconfig:GetDeployment\"],\"Resource\":\"*\",\"Effect\":\"Allow\"}]}"
}

resource "aws_iam_role" "IAMRoleCodePipeline" {
    path = "/"
    name = "${var.department.uppercase}-${var.codepipeline_project_variables.projectname}-CodePipeline"
    assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"codepipeline.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
    managed_policy_arns = [aws_iam_policy.IAMManagedPolicy.arn]
    max_session_duration = 3600
    tags = var.standard_tags
}

resource "aws_s3_bucket" "S3Bucket" {
    bucket      = "${var.department.uppercase}-${data.aws_caller_identity.current.account_id}-${var.codepipeline_project_variables.projectname}"
    acl         = "private"
    versioning {
      enabled = true
    }
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = var.s3_kms_key.arn
        }
      }
    }
#    logging {
#      target_bucket = var.S3Bucket.id
#      target_prefix = "log/s3_artifact/"
#    }
    tags = var.standard_tags
}

resource "aws_s3_bucket_public_access_block" "S3Bucket" {
  bucket = aws_s3_bucket.S3Bucket.id
  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "S3BucketPolicy" {
    bucket = aws_s3_bucket.S3Bucket.id
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
      "Sid": "AllowGetObject",
      "Effect": "Allow",
      "Principal": {
        "AWS": aws_iam_role.IAMRoleCodePipeline.arn
      },
      "Action": "s3:*",
      "Resource": [
        aws_s3_bucket.S3Bucket.arn,
        "${aws_s3_bucket.S3Bucket.arn}/*"
      ]
    },
    {
      "Sid": "DenyInsecureConnections",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.S3Bucket.arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
    ]
  })
}

resource "aws_codepipeline" "CodePipelinePipeline" {
    name = var.codepipeline_project_variables.projectname
    role_arn = aws_iam_role.IAMRoleCodePipeline.arn
    artifact_store {
        location = aws_s3_bucket.S3Bucket.id
        type = "S3"
    }
    stage {
        name = "Source"
        action {
                name = "SourceAction"
                category = "Source"
                owner = "AWS"
                configuration = {
                    PollForSourceChanges = "false"
                    S3Bucket = aws_s3_bucket.S3Bucket.id
                    S3ObjectKey = "${var.codepipeline_project_variables.projectnameshort}/${var.codepipeline_project_variables.artifactzip}"
                }
                provider = "S3"
                version = "1"
                output_artifacts = [
                    "SourceArtifact"
                ]
                run_order = 1
            }
    }
    stage {
        name = "Deploy${var.codepipeline_project_variables.projectnameshort}"
        action {
                name = "Deploy${var.codepipeline_project_variables.projectnameshort}"
                category = "Deploy"
                owner = "AWS"
                provider = "CloudFormationStackSet"
                version = "1"
                configuration = {
                    StackSetName = var.codepipeline_project_variables.stacksetname
                    TemplatePath = "SourceArtifact::${var.codepipeline_project_variables.templatepath}"
                    Capabilities = var.codepipeline_project_capabilities
                    PermissionModel = "SERVICE_MANAGED"
                    OrganizationsAutoDeployment = "Enabled"
                    DeploymentTargets = data.aws_organizations_organization.awsorg.roots[0].id
                    Regions = "ca-central-1,us-east-1"
                    FailureTolerancePercentage = 100
                }
                input_artifacts = [
                    "SourceArtifact"
                ]
                run_order = 1
            }
    }
  tags = var.standard_tags
}
