# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget
resource "aws_budgets_budget" "my-expensive-budget" {
  name         = "please-dont-let-me-poor"
  budget_type  = "COST"
  limit_amount = "1"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["jordhan.rdz@gmail.com"]
  }
}
