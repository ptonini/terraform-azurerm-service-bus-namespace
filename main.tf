resource "azurerm_servicebus_namespace" "this" {
  name                = var.name
  location            = var.rg.location
  resource_group_name = var.rg.name
  sku                 = var.sku
  capacity            = var.capacity
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags["business_unit"],
      tags["environment"],
      tags["product"],
      tags["subscription_type"],
      tags["environment_finops"]
    ]
  }
}

module "queues" {
  source                                  = "ptonini/service-bus-queue/azurerm"
  version                                 = "~> 1.0.0"
  for_each                                = var.queues
  name                                    = each.key
  namespace_id                            = azurerm_servicebus_namespace.this.id
  lock_duration                           = each.value.lock_duration
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  requires_session                        = each.value.requires_session
  default_message_ttl                     = each.value.default_message_ttl
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  max_delivery_count                      = each.value.max_delivery_count
  enable_batched_operations               = each.value.enable_batched_operations
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  enable_partitioning                     = each.value.enable_partitioning
}

module "topics" {
  source                                  = "ptonini/service-bus-topic/azurerm"
  version                                 = "~> 1.0.0"
  for_each                                = var.topics
  name                                    = each.key
  namespace_id                            = azurerm_servicebus_namespace.this.id
  subscriptions                           = each.value.subscriptions
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  default_message_ttl                     = each.value.default_message_ttl
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  enable_batched_operations               = each.value.enable_batched_operations
  enable_express                          = each.value.enable_express
  enable_partitioning                     = each.value.enable_partitioning
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  support_ordering                        = each.value.support_ordering
}
