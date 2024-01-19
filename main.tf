provider "github" {
  token = "ghp_..."
  owner = "Practical-DevOps-GitHub"
}

resource "github_repository" "repo" {
  name             = "github-terraform-task-blzzua"
  description      = "GitHub Repository"
  visibility       = "public"
  has_issues       = true
  has_projects     = true
  has_wiki         = false
  auto_init        = false
}

resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_branch" "develop_branch" {
  repository = github_repository.repo.name
  branch     = "develop"
  source_branch = "main"
}

resource "github_branch_default" "default_branch" {
  repository = github_repository.repo.name
  branch     = "develop"
  depends_on = [github_branch.develop_branch]
}

resource "github_branch_protection" "main_branch_protection" {
  repository_id = github_repository.repo.id
  pattern       = "main"
  required_status_checks {
    contexts = [] 
    strict   = "true"
  }
  required_pull_request_reviews {
    dismiss_stale_reviews        = false
    require_code_owner_reviews   = true
    required_approving_review_count = 0
  }
}

resource "github_branch_protection" "develop_branch_protection" {
  repository_id = github_repository.repo.id
  pattern       = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews        = false
    required_approving_review_count = 2
  }
}

resource "github_repository_file" "pull_request_template" {
  repository = github_repository.repo.name
  branch     = "main"
 overwrite_on_create = "true"
  file       = ".github/pull_request_template.md"
  content    = <<EOT
# Pull Request

## Description
Describe the purpose of this pull request.

## Changes Made
List the changes made in this pull request.

## Related Issues
- Include any related issue numbers and links.

## Checklist before requesting a review
- [ ] I have performed a self-review of my code.
- [ ] If it is a core feature, I have added thorough tests.
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update.
EOT
}


resource "github_repository_file" "CODEOWNERS" {
  repository = github_repository.repo.name
  branch     = "main"
 overwrite_on_create = "true"
  file       = ".github/CODEOWNERS"
  content    = <<EOT
# assign the user softservedata as the code owner for all the files in the main branch
main/   @softservedata
*       @blzzua
EOT
}

resource "github_repository_deploy_key" "DEPLOY_KEY" {
  repository = "repo"
  key        = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK05bzRYpUOVKdp+jMs7/IATIdR87fCT3NBAMeu6Vw3C as example"
  title      = "DEPLOY_KEY"
  read_only  = true
}

resource "github_actions_secret" "PAT" {
  repository       = "repo"
  secret_name      = "PAT"
  encrypted_value  = "ghp_..."
}
