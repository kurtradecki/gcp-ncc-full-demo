# ======= Timer to give APIs time to fully enable =======
resource "time_sleep" "wait_timer" {
  create_duration = "120s"
  depends_on      = [google_project_service.apis, module.bool_org_policy, module.list_org_policy]
}
