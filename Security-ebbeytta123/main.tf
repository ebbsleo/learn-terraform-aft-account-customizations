# Configure Amazon GuardDuty
resource "aws_guardduty_detector" "this" {
  enable = true

  # Optional settings
  finding_publishing_frequency = "SIX_HOURS" # Frequency for publishing findings. Valid values: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS
  datasources {
    # Enable or disable specific data sources for GuardDuty
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }
}

# Create SNS topic for GuardDuty findings
resource "aws_sns_topic" "guardduty_findings" {
  name = "guardduty-findings"
}

# Subscribe to SNS topic
resource "aws_sns_topic_subscription" "guardduty_findings_subscription" {
  topic_arn = aws_sns_topic.guardduty_findings.arn
  protocol  = "email"
  endpoint  = "example@example.com" # Replace with your email address
}

# Configure GuardDuty to publish findings to SNS topic
resource "aws_guardduty_publishing_destination" "findings_destination" {
  detector_id     = aws_guardduty_detector.this.id
  destination_arn = aws_sns_topic.guardduty_findings.arn
  kms_key_arn     = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab" # Optional KMS key ARN for encryption
}
