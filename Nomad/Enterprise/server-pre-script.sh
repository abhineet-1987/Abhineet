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
sudo touch /etc/nomad.d/server.hcl
sudo touch /etc/nomad.d/license.hclic
sudo chmod -R 755 /etc/nomad.d

# Create files nomad.hcl, server.hcl and license.hclic at /etc/nomad.d as per your requirement and then execute
# sudo systemctl enable nomad
# sudo systemctl start nomad
# sudo systemctl status nomad

