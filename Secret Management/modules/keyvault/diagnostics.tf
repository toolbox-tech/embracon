resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name               = "kv-diag-logs"
  target_resource_id = azurerm_key_vault.kv.id
  storage_account_id = var.diagnostics_storage_account_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}