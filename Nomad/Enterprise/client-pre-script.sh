# Go to to https://releases.hashicorp.com/nomad/ to check the release version to be deployed

export NOMAD_VERSION="1.10.5+ent"
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
sudo chown root:root nomad
sudo mv nomad /usr/local/bin/
nomad version

nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad

sudo mkdir --parents /opt/nomad
chmod -R 777 /opt/nomad
sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad

sudo touch /etc/systemd/system/nomad.service

sudo mkdir --parents /etc/nomad.d
sudo touch /etc/nomad.d/nomad.hcl
sudo touch /etc/nomad.d/client.hcl
sudo touch /etc/nomad.d/license.hclic
sudo chmod -R 755 /etc/nomad.d

# Nomad client specific changes:-

# Install dependencies
echo "Installing Dependencies"
sudo yum update -y
sudo yum install -y jq
sudo yum install -y yum-utils

# Install Docker
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker

# Install cni plugin on nomad client machine
export ARCH_CNI=$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)
export CNI_PLUGIN_VERSION=v1.6.2
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGIN_VERSION}/cni-plugins-linux-${ARCH_CNI}-${CNI_PLUGIN_VERSION}".tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
sudo rm -rf cni-plugins.tgz

# Install consul cni plugin on nomad client machine
# https://developer.hashicorp.com/nomad/docs/deploy#install-consul-cni-plugin
sudo yum install -y consul-cni   # for amazon linux, for other systems refer above link

# Create files nomad.hcl, client.hcl and license.hclic at /etc/nomad.d as per your requirement and file nomad.service at /etc/systemd/system and then execute
# sudo systemctl enable nomad
# sudo systemctl start nomad
# sudo systemctl status nomad
