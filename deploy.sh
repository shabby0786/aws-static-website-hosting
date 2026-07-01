#!/bin/bash

# ==========================================================
# Deploy script for NimbusCraft Interiors static website
# Syncs the /website folder to S3 and invalidates the
# CloudFront cache so visitors immediately see the update.
#
# Requirements:
#   - AWS CLI installed and configured (aws configure)
#   - IAM permissions for s3:PutObject and cloudfront:CreateInvalidation
#
# Usage:
#   ./deploy.sh
# ==========================================================

set -e  # stop the script if any command fails

# ---- EDIT THESE THREE VALUES FOR YOUR PROJECT ----
S3_BUCKET_NAME="nimbuscraft-website-prod"
CLOUDFRONT_DISTRIBUTION_ID="REPLACE_WITH_YOUR_DISTRIBUTION_ID"
LOCAL_WEBSITE_FOLDER="./website"
# ---------------------------------------------------

echo "Step 1: Uploading website files to S3 bucket: $S3_BUCKET_NAME"
aws s3 sync "$LOCAL_WEBSITE_FOLDER" "s3://$S3_BUCKET_NAME" --delete

echo "Step 2: Creating CloudFront invalidation to clear cached files"
aws cloudfront create-invalidation \
  --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
  --paths "/*"

echo "Deployment complete. Changes will be live within a few minutes."
