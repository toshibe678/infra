resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = "github-actions-pool"
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_provider_id = "github-actions-provider"
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id

  display_name        = "GitHub OIDC"
  description         = "GitHub OIDC identity pool provider for GitHub Actions in Your Org"
  disabled            = false
  attribute_condition = "\"${var.org_name}\" == assertion.repository_owner"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"         = "assertion.sub"
    "attribute.repository"   = "assertion.repository"
    "attribute.actor"        = "assertion.actor"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
    "attribute.org_repo_branch"  = "assertion.repository + \"/\" + assertion.ref.extract('refs/heads/{branch}')"
  }
}

resource "google_service_account" "github_actions" {
  account_id = "github-actions"
}

resource "google_service_account_iam_binding" "github_actions_iam_workload_identity_bind" {
  service_account_id = google_service_account.github_actions.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.org-repo-branch/${var.org_name}/*/develop",
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.org-repo-branch/${var.org_name}/*/master",
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.org-repo-branch/${var.org_name}/*/main"
  ]
}

resource "google_project_iam_binding" "github_actions_pr_agent_role_bind" {
  project = var.project
  role    = google_project_iam_custom_role.pr_agent_role.name
  members = ["serviceAccount:${google_service_account.github_actions.email}"]
}
# Github Actionsから呼び出すPR-Agent用カスタムロールの作成
resource "google_project_iam_custom_role" "pr_agent_role" {
  role_id     = "PRAgentRole"
  title       = "PR Agent Role"
  description = "Role for PR Agent"
  permissions = [
    "aiplatform.endpoints.predict"
  ]
  stage   = "ALPHA"
  project = var.project
}
