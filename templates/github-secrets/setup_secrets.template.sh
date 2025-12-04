#!/bin/bash
# GitHub Secrets Setup - TEMPORARY FILE
# Repository: {{REPO}}
# Generated: {{TIMESTAMP}}
# DO NOT COMMIT - DELETE AFTER USE

set -e

REPO="{{REPO}}"

echo "Configuring secrets for $REPO..."

{{SECRETS_BLOCK}}

echo ""
echo "Secrets configured successfully."
echo "Verifying..."
gh secret list --repo "$REPO"

echo ""
echo "DELETE THIS FILE NOW:"
echo "  rm $0"
