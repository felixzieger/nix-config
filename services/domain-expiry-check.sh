#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: domain-expiry-check <domains-json>" >&2
  exit 2
fi

domains_file="$1"
rdap_parser="@rdap_parser@"

if ! jq -e 'length > 0' "$domains_file" >/dev/null 2>&1; then
  exit 0
fi

status=0
declare -a issues=()

declare -A default_rdap_base=(
  [de]="https://rdap.denic.de/domain/"
  [com]="https://rdap.verisign.com/com/v1/domain/"
  [net]="https://rdap.verisign.com/net/v1/domain/"
  [org]="https://rdap.publicinterestregistry.net/rdap/org/domain/"
)

while IFS= read -r item; do
  name=$(jq -r '.name' <<<"$item")
  warn_days=$(jq -r '.warnDays' <<<"$item")
  rdap_url=$(jq -r '.rdapUrl // empty' <<<"$item")
  tld="${name##*.}"

  # Handle .de domains with DENIC whois
  if [[ "$tld" == "de" ]]; then
    if ! whois_response=$(whois -h whois.denic.de "$name" 2>/dev/null); then
      issues+=("Failed to fetch DENIC whois data for ${name}")
      status=1
      continue
    fi

    domain_status=$(echo "$whois_response" | grep -i "^Status:" | awk '{print $2}')

    if [[ "$domain_status" == "free" ]]; then
      issues+=("Domain ${name} is available for registration (expired or never registered)")
      status=1
    elif [[ "$domain_status" == "connect" ]]; then
      # Domain is active, no expiration date available from DENIC
      continue
    else
      issues+=("Unknown status '$domain_status' for ${name}")
      status=1
    fi
    continue
  fi

  # Handle non-.de domains with RDAP
  if [[ -z "$rdap_url" ]]; then
    if [[ -n "${default_rdap_base[$tld]:-}" ]]; then
      rdap_url="${default_rdap_base[$tld]}${name}"
    else
      rdap_url="https://rdap.org/domain/${name}"
    fi
  fi

  if ! response=$(curl --fail --silent --show-error --connect-timeout 10 --max-time 30 "$rdap_url"); then
    issues+=("Failed to fetch RDAP data for ${name} from ${rdap_url}")
    status=1
    continue
  fi

  expiry=$(jq -rf "${rdap_parser}" <<<"$response")

  if [[ -z "$expiry" ]]; then
    issues+=("No expiration event found in RDAP data for ${name}")
    status=1
    continue
  fi

  if ! expiry_ts=$(date -d "$expiry" +%s 2>/dev/null); then
    issues+=("Could not parse expiration date '$expiry' for ${name}")
    status=1
    continue
  fi

  now=$(date -u +%s)
  seconds_left=$(( expiry_ts - now ))
  days_left=$(( seconds_left / 86400 ))

  if (( seconds_left < 0 )); then
    issues+=("Domain ${name} expired on ${expiry}")
    status=1
  elif (( days_left <= warn_days )); then
    issues+=("Domain ${name} expires on ${expiry} (in ${days_left} days, threshold ${warn_days})")
    status=1
  fi

done < <(jq -c '.[]' "$domains_file")

if (( status != 0 )); then
  echo "Domain expiration issues detected:"
  for issue in "${issues[@]}"; do
    echo " - ${issue}"
  done
fi

exit $status
