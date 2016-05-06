#!/bin/bash
# Helper script to repetitively test things quickly


bash baseline.sh
if [ $? -ne 0 ]; then
  echo 'Something broke in the baseline'
  exit 1
fi

yum -y install yum-plugin-priorities rubygems centos-release-openstack-mitaka
yum -y install puppet python-openstackclient
gem install r10k

pushd /etc/puppet
PUPPETFILE=/root/centos-cloud/puppet/Puppetfile r10k puppetfile install -v
mv /root/centos-cloud/puppet/modules/centos_cloud modules/
echo "${1} controller.openstack.ci.centos.org" >> /etc/hosts
puppet apply -e "include ::centos_cloud::compute" || exit 1
popd

# make sure we got added in
source /root/openrc
openstack hypervisor list | grep -i $(hostname )
if [ $? -eq 0 ]; then 
  echo 'Success!'
fi
