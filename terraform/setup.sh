#! /bin/bash
#

apt update --yes
apt upgrade --yes
apt install build-essential python3-pip python3-dev libblas-dev gfortran liblapack-dev awscli git --yes

export QIIME2_USER=ubuntu
export QIIME2_S3_BUCKET=qiime2-ec2-test
export QIIME2_EC2_AIM_ROLE=qiime2Ec2Role

export MINICONDA_INSTALLER=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
export MINICONDA_DOWNLOAD_PATH=/opt

export MINICONDA_PREFIX="/opt/miniconda"
export MPLBACKEND=agg
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

export QIIME2_VERSION=2024.2
export QIIME2_DISTRIBUTION=amplicon

wget -q $MINICONDA_INSTALLER -O ${MINICONDA_DOWNLOAD_PATH}/miniconda.sh
bash /opt/miniconda.sh -b -u -p $MINICONDA_PREFIX
export PATH="$MINICONDA_PREFIX/bin:$PATH"

conda update conda --yes
conda init bash --system

#conda install wget --yes

wget https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.2-py38-linux-conda.yml -O ${MINICONDA_DOWNLOAD_PATH}/qiime2-amplicon-2024.2-py38-linux-conda.yml
conda env create -n qiime2-amplicon-2024.2 --file ${MINICONDA_DOWNLOAD_PATH}/qiime2-amplicon-2024.2-py38-linux-conda.yml

# Add user bash configuration
QIIME2_BASH_CONFIG=/etc/profile.d/qiime2_activate.sh
echo "export PATH=$MINICONDA_PREFIX/bin:$PATH" >> ${QIIME2_BASH_CONFIG}
echo "export MPLBACKEND=agg" >> ${QIIME2_BASH_CONFIG}
echo "export LC_ALL=C.UTF-8" >> ${QIIME2_BASH_CONFIG}
echo "export LANG=C.UTF-8" >> ${QIIME2_BASH_CONFIG}
echo "conda activate qiime2-${QIIME2_DISTRIBUTION}-${QIIME2_VERSION}" >> ${QIIME2_BASH_CONFIG}

chmod +x ${QIIME2_BASH_CONFIG}

echo "source ${QIIME2_BASH_CONFIG}" >> /home/${QIIME2_USER}/.bashrc

# Mount S3 bucket {{{
#

wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb -O /opt/mount-s3.deb
apt install -y /opt/mount-s3.deb

su - ${QIIME2_USER} -c "mkdir -p /home/${QIIME2_USER}/files"
SYSTEMD_MOUNT_S3_SERVICE=/etc/systemd/system/mount_s3.service

cat << EOF > /etc/systemd/system/mount_s3.service
# Mount S3
[Unit]
Description=Mountpoint for Amazon S3 mount
Wants=network.target
AssertPathIsDirectory=/home/${QIIME2_USER}/files

[Service]
Type=forking
User=${QIIME2_USER}
Group=${QIIME2_USER}
ExecStart=/usr/bin/mount-s3 ${QIIME2_S3_BUCKET} /home/${QIIME2_USER}/files --allow-overwrite --allow-delete
ExecStop=/usr/bin/fusermount -u /home/${QIMIME2_USER}/files

[Install]
WantedBy=remote-fs.target
EOF

systemctl daemon-reload
systemctl start mount_s3.service
# }}}
