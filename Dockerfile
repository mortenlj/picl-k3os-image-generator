FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y gnupg software-properties-common && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && \
    add-apt-repository ppa:rmescandon/yq

RUN apt-get update && \
    apt-get install -y \
        wget \
        parted \
        kpartx \
        dosfstools \
        binutils \
        p7zip-full \
        yq \
        jq \
        sudo

COPY . /builder
WORKDIR /builder

CMD ["/bin/bash"]
