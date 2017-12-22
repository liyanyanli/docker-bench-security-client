#!/bin/sh

logit "\n"
info "Docker Daemon Configuration"

# 2.1
check_2_1="Restrict network traffic between containers"
get_docker_effective_command_line_args '--icc' | grep "false" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "$check_2_1"
else
  warn "$check_2_1"
fi

# 2.2
check_2_2="Set the logging level"
get_docker_effective_command_line_args '-l' >/dev/null 2>&1
if [ $? -eq 0 ]; then
  get_docker_effective_command_line_args '-l' | grep "info" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    pass "$check_2_2"
  else
    warn "$check_2_2"
  fi
else
  pass "$check_2_2"
fi

# 2.3
check_2_3="Allow Docker to make changes to iptables"
get_docker_effective_command_line_args '--iptables' | grep "false" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  warn "$check_2_3"
else
  pass "$check_2_3"
fi

# 2.4
check_2_4="Do not use insecure registries"
get_docker_effective_command_line_args '--insecure-registry' | grep "insecure-registry" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  warn "$check_2_4"
else
  pass "$check_2_4"
fi

# 2.5
check_2_5="Do not use the aufs storage driver"
docker info 2>/dev/null | grep -e "^Storage Driver:\s*aufs\s*$" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  warn "$check_2_5"
else
  pass "$check_2_5"
fi

# 2.6
check_2_6="Configure TLS authentication for Docker daemon"
get_docker_cumulative_command_line_args '-H' | grep -vE '(unix|fd)://' >/dev/null 2>&1
if [ $? -eq 0 ]; then
  get_command_line_args docker | grep "tlsverify" | grep "tlskey" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    pass "$check_2_6"
    info "     * Docker daemon currently listening on TCP"
  else
    warn "$check_2_6"
    warn "     * Docker daemon currently listening on TCP without --tlsverify"
  fi
else
  info "$check_2_6"
  info "     * Docker daemon not listening on TCP"
fi

# 2.7
check_2_7="Set default ulimit as appropriate"
get_docker_effective_command_line_args '--default-ulimit' | grep "default-ulimit" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "$check_2_7"
else
  info "$check_2_7"
  info "     * Default ulimit doesn't appear to be set"
fi

# 2.8
check_2_8="Enable user namespace support"
get_docker_effective_command_line_args '--userns-remap' | grep "userns-remap" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "$check_2_8"
else
  warn "$check_2_8"
fi

# 2.9
check_2_9="Confirm default cgroup usage"
get_docker_effective_command_line_args '--cgroup-parent' | grep "cgroup-parent" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  info "$check_2_9"
  info "     * Confirm cgroup usage"
else
  pass "$check_2_9"
fi

# 2.10
check_2_10="Do not change base device size until needed"
get_docker_effective_command_line_args '--storage-opt' | grep "dm.basesize" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  warn "$check_2_10"
else
  pass "$check_2_10"
fi

# 2.11
check_2_11="Use authorization plugin"
get_docker_effective_command_line_args '--authorization-plugin' | grep "authorization-plugin" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "$check_2_11"
else
  warn "$check_2_11"
fi

# 2.12
check_2_12="Configure centralized and remote logging"
get_docker_effective_command_line_args '--log-driver' | grep "log-driver" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "$check_2_12"
else
  warn "$check_2_12"
fi

# 2.13
check_2_13="Disable operations on legacy registry (v1)"
get_docker_effective_command_line_args '--disable-legacy-registry' | grep "disable-legacy-registry" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "$check_2_13"
else
  warn "$check_2_13"
fi
