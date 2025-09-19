#!/bin/bash

# Example input variables
# (In actual use, these are set by the deployment system/environment.)
# API_KEY="${API_KEY:-}"
# REGION="${REGION:-}"

# Validation function for empty value
validate_not_empty() {
  local var_name="$1"
  local value="$2"
  if [[ -z "$value" ]]; then
    echo "ERROR: $var_name must not be empty."
    exit 1
  fi
}

# Optional: Validation function for region (example: restrict to 'us-east', 'eu-de', etc.)
validate_region() {
  local value="$1"
  case "$value" in
    "us-east"|"eu-de"|"au-syd")
      ;;
    *)
      echo "ERROR: REGION value '$value' is invalid. Must be one of 'us-east', 'eu-de', 'au-syd'."
      exit 1
      ;;
  esac
}

# Optional: Validate API key pattern (example: just a length check)
validate_apikey() {
  local value="$1"
  if [[ ${#value} -lt 20 ]]; then
    echo "ERROR: API_KEY appears too short."
    exit 1
  fi
}

# Run validations
# validate_not_empty "API_KEY" "$API_KEY"
# validate_apikey "$API_KEY"

# validate_not_empty "REGION" "$REGION"
# validate_region "$REGION"

echo "Input varaiables: $region $zone"
exit 0