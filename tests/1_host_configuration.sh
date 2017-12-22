#!/bin/sh

logit ""
info "Host Configuration"

# 1.1
check_1_1="Create a separate partition for containers"
grep /var/lib/docker /etc/fstab >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "$check_1_1"
else
  warn "$check_1_1"
fi

# 1.2
check_1_2="Use an updated Linux Kernel"
kernel_version=$(uname -r | cut -d "-" -f 1)
do_version_check 3.10 "$kernel_version"
if [ $? -eq 11 ]; then
  warn "$check_1_2"
else
  pass "$check_1_2"
fi

# 1.4
check_1_4="Remove all non-essential services from the host - Network"
# Check for listening network services.
listening_services=$(netstat -na | grep -v tcp6 | grep -v unix | grep -c LISTEN)
if [ "$listening_services" -eq 0 ]; then
  warn "Failed to get listening services for check: $check_1_4"
else
  if [ "$listening_services" -gt 5 ]; then
    warn "$check_1_4"
    warn "     * Host listening on: $listening_services ports"
else
    pass "$check_1_4"
  fi
fi

# 1.5
check_1_5="Keep Docker up to date"
docker_version=$(docker version | grep -i -A1 '^server' | grep -i 'version:' \
  | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
docker_current_version="1.12.3"
docker_current_date="2016-10-26"
do_version_check "$docker_current_version" "$docker_version"
if [ $? -eq 11 ]; then
  warn "$check_1_5"
  warn "      * Using $docker_version, when $docker_current_version is current as of $docker_current_date"
  info "      * Your operating system vendor may provide support and security maintenance for docker"
else
  pass "$check_1_5"
  info "      * Using $docker_version which is current as of $docker_current_date"
  info "      * Check with your operating system vendor for support and security maintenance for docker"
fi

# 1.6
check_1_6="Only allow trusted users to control Docker daemon"
docker_users=$(getent group docker)
info "$check_1_6"
for u in $docker_users; do
  info "     * $u"
done

# 1.7
check_1_7="Audit docker daemon - /usr/bin/docker"
file="/usr/bin/docker"
command -v auditctl >/dev/null 2>&1
if [ $? -eq 0 ]; then
  auditctl -l | grep "$file" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    pass "$check_1_7"
  else
    warn "$check_1_7"
  fi
else
  warn "Failed to inspect: auditctl command not found."
fi

# 1.8
check_1_8="Audit Docker files and directories - /var/lib/docker"
directory="/var/lib/docker"
if [ -d "$directory" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $directory >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_8"
    else
      warn "$check_1_8"
    fi
  else
    warn "Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_8"
  info "     * Directory not found"
fi

# 1.9
check_1_9="Audit Docker files and directories - /etc/docker"
directory="/etc/docker"
if [ -d "$directory" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $directory >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_9"
    else
      warn "$check_1_9"
    fi
  else
    warn "Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_9"
  info "     * Directory not found"
fi

# 1.10
check_1_10="Audit Docker files and directories - docker.service"
file="$(get_systemd_service_file docker.service)"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep "$file" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_10"
    else
      warn "$check_1_10"
    fi
  else
    warn "Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_10"
  info "     * File not found"
fi

# 1.11
check_1_11="Audit Docker files and directories - docker.socket"
file="$(get_systemd_service_file docker.socket)"
if [ -e "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep "$file" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_11"
    else
      warn "$check_1_11"
    fi
  else
    warn "Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_11"
  info "     * File not found"
fi

# 1.12
check_1_12="Audit Docker files and directories - /etc/default/docker"
file="/etc/default/docker"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_12"
    else
      warn "$check_1_12"
    fi
  else
    warn "Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_12"
  info "     * File not found"
fi

# 1.13
check_1_13="Audit Docker files and directories - /etc/docker/daemon.json"
file="/etc/docker/daemon.json"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_13"
    else
      warn "$check_1_13"
    fi
  else
    warn "Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_13"
  info "     * File not found"
fi

# 1.14
check_1_14="Audit Docker files and directories - /usr/bin/docker-containerd"
file="/usr/bin/docker-containerd"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_14"
    else
      warn "$check_1_14"
    fi
  else
    warn "Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_14"
  info "     * File not found"
fi

# 1.15
check_1_15="Audit Docker files and directories - /usr/bin/docker-runc"
file="/usr/bin/docker-runc"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_15"
    else
      warn "$check_1_15"
    fi
  else
    warn "Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_15"
  info "     * File not found"
fi
