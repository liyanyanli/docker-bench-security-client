#!/bin/sh

logit "\n"
info "Container Images and Build Files"

# 4.1
check_4_1="Create a user for the container"

# If container_users is empty, there are no running containers
if [ -z "$containers" ]; then
  info "$check_4_1"
  info "     * No containers running"
else
  # We have some containers running, set failure flag to 0. Check for Users.
  fail=0
  # Make the loop separator be a new-line in POSIX compliant fashion
  set -f; IFS=$'
'
  for c in $containers; do
    user=$(docker inspect --format 'User={{.Config.User}}' "$c")

    if [ "$user" = "User=" -o "$user" = "User=[]" -o "$user" = "User=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_4_1"
        warn "     * Running as root: $c"
        fail=1
      else
        warn "     * Running as root: $c"
      fi
    fi
  done
  # We went through all the containers and found none running as root
  if [ $fail -eq 0 ]; then
      pass "$check_4_1"
  fi
fi
# Make the loop separator go back to space
set +f; unset IFS

# 4.5
check_4_5="Enable Content trust for Docker"
if [ "x$DOCKER_CONTENT_TRUST" = "x1" ]; then
  pass "$check_4_5"
else
  warn "$check_4_5"
fi
