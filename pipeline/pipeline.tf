resource "aws_codebuild_project" "this" {
  name         = "codebuild-${var.CodeRepoName}"
  description  = "Plan stage CodeBuild Project for ${var.StackName}"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.env_name
        type  = "PLAINTEXT"
        value = (length(split("/", environment_variable.value.env_value)) > 1) ? data.aws_ssm_parameter.dynamic["${environment_variable.value.env_name}"].value : ((environment_variable.value.env_value == "OutputBucketName") ? data.aws_cloudformation_stack.git-2-s3["${environment_variable.value.env_name}"].outputs["OutputBucketName"] : environment_variable.value.env_value)
      }
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = var.build_spec_file
  }

  depends_on = [
    data.aws_ssm_parameter.dynamic,
  ]
}

resource "aws_codepipeline" "this" {
  name     = var.StackName
  role_arn = aws_iam_role.tf-codepipeline-role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.terraform_codepipeline_artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["${var.StackName}-SourceArtifact"]
      configuration = {
        Repo                 = var.CodeRepoName
        Branch               = var.CodeRepoBranch
        PollForSourceChanges = false
        Owner                = var.CodeRepoOwner
        OAuthToken           = data.aws_ssm_parameter.CodeRepoOauthToken.value
      }
      run_order = 1
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["${var.StackName}-SourceArtifact"]
      output_artifacts = ["${var.StackName}-BuildArtifact"]
      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
      run_order = 1
    }
  }
}

resource "aws_codepipeline_webhook" "this" {
  name            = "${var.StackName}-webhook-${var.env}"
  authentication  = "GITHUB_HMAC"
  target_pipeline = aws_codepipeline.this.name
  target_action   = "Source"
  authentication_configuration {
    secret_token = data.aws_ssm_parameter.CodeRepoOauthToken.value
  }
  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}
