# Base image
FROM continuumio/miniconda3
LABEL maintainer="Albert Cañellas <albert.canellas@bsc.es>"

# Set env variables for pele_platform
ENV PELE="/home/src/PELE"
ENV SCHRODINGER="/home/src/Schrodinger/binMaestro"
ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV NUMEXPR_MAX_THREADS=45
ARG DEBIAN_FRONTEND=noninteractive

# Install other dependencies (g++,gcc,gfortran)
RUN apt update && \
    apt-get install -y build-essential libblas-dev liblapack-dev libssl-dev cmake libopenmpi-dev \
    zip uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev pkg-config cryptsetup debootstrap libglib2.0-dev

WORKDIR /home/src
# Installing Openmpi
WORKDIR /home/src/open-mpi
ARG OPENMPI_VERSION="4.1.2"
RUN wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-${OPENMPI_VERSION}.tar.gz
RUN tar xfz openmpi-${OPENMPI_VERSION}.tar.gz && \
    cd openmpi-${OPENMPI_VERSION} && \
    ./configure && \
    make && \
    make install && \
    rm -rf /home/src/open-mpi/openmpi-${OPENMPI_VERSION}.tar.gz

# Install Go 
WORKDIR /home/src
ARG GO_VERSION="1.19.3"
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -zxvf go${GO_VERSION}.linux-amd64.tar.gz && \
    mv ./go /usr/local/go && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

# Install Singularity
WORKDIR /home/src/singularity
RUN wget https://github.com/sylabs/singularity/releases/download/v3.10.4/singularity-ce-3.10.4.tar.gz && \
    tar -xzvf singularity-ce-3.10.4.tar.gz && \
    cd /home/src/singularity/singularity-ce-3.10.4 && \
    ./mconfig && \
    cd /home/src/singularity/singularity-ce-3.10.4/builddir && \
    make && \
    make install

# Installing Schrodinger
WORKDIR /home/src/Schrodinger
ADD Maestro_2020-1_Linux-x86_64_Academic.tar /home/src/Schrodinger
RUN mkdir binMaestro && mkdir scratch && mkdir thirdparty-dir
RUN cd Maestro_2020-1_Linux-x86_64_Academic && \
    ./INSTALL -b maestro-v12.3-Linux-x86_64.tar.gz -s /home/src/Schrodinger/binMaestro -k /home/src/Schrodinger/scratch -t /home/src/Schrodinger/thirdparty-dir && \
    rm -rf /home/src/Schrodinger/Maestro_2020-1_Linux-x86_64_Academic

# Install pele_platform dependencies
RUN conda create --name pele_platform-satu
RUN echo "conda activate pele_platform-satu" >> ~/.bashrc
RUN conda install python=3.8 && \
    conda install -c conda-forge -c nostrumbiodiscovery -c eapm -c albertcs pele_platform=1.6.3.3

# Going to the working directory in the sharedDirectory
WORKDIR /home/pele_platform

# Launch the platform
CMD ["sh", "-c", "python -m pele_platform.main /home/pele_platform/input.yaml"]
