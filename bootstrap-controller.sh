#!/bin/bash
# Helper script to repetitively test things quickly

. baseline.sh
if [ $? -ne 0 ]; then
  echo 'Something broke in the baseline'
  exit 1
fi

echo "127.0.0.1 controller.openstack.ci.centos.org" >>/etc/hosts
puppet apply -e "include ::centos_cloud::controller" || exit 1

# Sanity check
source /root/openrc
openstack endpoint list
if [ $? -eq 0 ]; then
  echo 'Sanity check successful!'
fi
