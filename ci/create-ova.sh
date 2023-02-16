#!/bin/bash

PACKAGES=$(jq --raw-output < /ci/packages_minimal.json '.packages|join(" ")')
ARCH=$(uname -m)
# size in MB
DISKSIZE=2048
CFG=$(pwd)/minimal.cfg
OVA_NAME=minimal
REPO=/repo
TEMPLATE=template-hw20.ovf

create_repo()
{
    mkdir -p /repo
    tdnf install -y --alldeps --downloadonly --downloaddir=/repo ${PACKAGES}
    pushd /repo
    createrepo .
    popd
}

install_open_vmdk()
{
    pushd /workdir
    curl -LO https://github.com/vmware/open-vmdk/archive/master.tar.gz
    tar zxf master.tar.gz
    pushd open-vmdk-master
    make
    make install
    popd
    popd
}

create_disk()
{
    dd if=/dev/zero of=/workdir/${OVA_NAME}.img bs=1M count=${DISKSIZE}
}

install_poi()
{
    pushd /poi
    pip3 install .
    popd
}

install_os()
{
    export LOOP_DEVICE=$(losetup --show -f /workdir/${OVA_NAME}.img)
    echo "using loop device ${LOOP_DEVICE}"
    mkdir -p /mnt/photon-root/
    photon-installer -i ova -v 4.0 -p /repo -c ${CFG} -w /mnt/photon-root/
    losetup -d ${LOOP_DEVICE}
}

create_ova()
{
    pushd /workdir
    # TODO: tools version
    vmdk-convert ${OVA_NAME}.img ${OVA_NAME}.vmdk
    mkova.sh ${OVA_NAME} ./open-vmdk-master/ova/${TEMPLATE} ${OVA_NAME}.vmdk
    popd
}

while getopts 'c:o:s:t:' c
do
    case $c in
        c) CFG=${OPTARG} ;;
        o) OVA_NAME=${OPTARG} ;;
        s) DISKSIZE=${OPTARG} ;;
        t) TEMPLATE=${OPTARG} ;;
    esac
done

shift $((OPTIND-1))
if [ ! -f ${CFG} ] ; then
    echo "${CFG} does not exist"
    exit 1
fi

install_open_vmdk
install_poi
[ -d /repo/repodata ] || create_repo
create_disk
install_os
create_ova
