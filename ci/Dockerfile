FROM photon:4.0

RUN tdnf makecache
RUN tdnf -y update
RUN tdnf -y install \
    build-essential zlib-devel \
    util-linux coreutils findutils cdrkit \
    gptfdisk grub2 grub2-pc e2fsprogs kpartx dosfstools \
    createrepo rpm jq \
    python3 python3-pip python3-setuptools python3-curses \
    git

VOLUME /repo /workdir /ci
