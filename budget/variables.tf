variable "name" {
  description = "Budget name."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group resource ID used as the budget scope."
  type        = string
}

variable "amount" {
  description = "Monthly budget in the subscription billing currency."
  type        = number
}

variable "start_date" {
  description = "Budget start date in RFC3339 format; must be the first day of a month."
  type        = string
}

variable "contact_emails" {
  description = "Email addresses notified at each threshold."
  type        = set(string)
}
