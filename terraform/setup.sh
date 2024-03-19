#! /bin/bash
#

apt update && apt upgrade
export MINICONDA_PREFIX="$HOME/miniconda"
export MPLBACKEND=agg

cd $HOME
echo "export PATH=$MINICONDA_PREFIX/bin:$PATH" >> $HOME/.bashrc
echo "export MPLBACKEND=agg" >> $HOME/.bashrc
echo "export LC_ALL=C.UTF-8" >> $HOME/.bashrc
echo "export LANG=C.UTF-8" >> $HOME/.bashrc
echo "source activate qiime2-${QIIME2_RELEASE}" >> $HOME/.bashrc
echo "source tab-qiime" >> $HOME/.bashrc

wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $MINICONDA_PREFIX
export PATH="$MINICONDA_PREFIX/bin:$PATH"

apt update
