#!/bin/bash

C_ERROR='\033[31m'
C_OK='\033[32m'
C_INFO='\033[94m'
C_HEADER='\033[95m'
C_END='\033[m'

function colorize() {
  echo -en "${1}${2}${C_END}"
}

function print_task() {
  echo -e "$(colorize "${C_INFO}" "${*}")"
}

function print_header() {
  echo -e "$(colorize "${C_HEADER}" "${*}")"
}

function print_success() {
  echo -e "$(colorize "${C_OK}" "${*}")"
}

function print_error() {
  echo -e "$(colorize "${C_ERROR}" "${*}")"
}

function fail_out() {
  print_error "${*}"
  exit 1
}

function select_openvpn_config() {
  configs_directory=${1}
  country_code=${2}

  if [[ ${country_code} != '' ]]; then
    echo pass
  fi


  # TODO: fix config selection to be able to use different country codes
  find "${configs_directory}" -name "*us*${CONNECTION_TYPE}.ovpn" | head -n 1
}

print_header 'Starting to build surfshark proxy server'

print_task 'Removing stale temporary directory'
rm -rf .temp

print_task 'Creating temporary directory'
mkdir -p .temp

print_task 'Downloading openvpn_configs.zip'
wget https://my.surfshark.com/vpn/api/v1/server/configurations -O .temp/openvpn_configs.zip

print_task 'Extracting openvpn_configs.zip to openvpn_configs'
unzip .temp/openvpn_configs.zip -d .temp/openvpn_configs

openvpn_config_file=$(select_openvpn_config .temp/openvpn_configs)
print_success "Successfully selected openvpn config: ${openvpn_config_file}"

print_task 'Creating credentials file'
print_task 'Verifying if the credentials are properly passed to the container'

if [[ "${SURFSHARK_USERNAME}" == '' ]]; then
  fail_out 'SURFSHARK_USERNAME cannot be empty'
fi

if [[ "${SURFSHARK_PASSWORD}" == '' ]]; then
  fail_out 'SURFSHARK_PASSWORD cannot be empty'
fi

# shellcheck disable=SC2059
printf "${SURFSHARK_USERNAME}\n${SURFSHARK_PASSWORD}" >.temp/credentials.txt
print_success 'Successfully created the credentials file'

print_task "Starting openvpn connection using: ${openvpn_config_file}"
openvpn --config "${openvpn_config_file}" --auth-user-pass ".temp/credentials.txt" --daemon --dev 'tun0' --dev-type 'tun'

if [[ ${?} != 0 ]]; then
  fail_out 'Openvpn command failed'
fi

public_ip=$(curl https://ipinfo.io/ip)
print_success "Successfully started openvpn connection. The new public ip address is: ${public_ip}"

exec privoxy --no-daemon ./privoxy.cfg
