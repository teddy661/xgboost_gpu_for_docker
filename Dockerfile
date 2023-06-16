FROM  nvidia/cuda:11.8.0-cudnn8-devel-rockylinux8 AS build
SHELL ["/bin/bash", "-c"]
ENV PY_VERSION=3.11.4
RUN dnf install epel-release -y
RUN /usr/bin/crb enable
RUN dnf update --disablerepo=cuda -y
RUN dnf install \
                curl \
                perl-devel \
                libcurl-devel \
                expat-devel \
                gettext-devel \
                gcc \
                cmake \
                openssl-devel \
                bzip2-devel \
                xz xz-devel \
                findutils \
                libffi-devel \
                zlib-devel \
                wget \
                make \
                ncurses ncurses-devel \
                readline-devel \
                uuid \
                tcl-devel tcl tk-devel tk \
                sqlite-devel \
                #tensorrt-8.5.3.1-1.cuda11.8 \
                #tensorrt-8.6.0.12-1.cuda11.8 \
                gcc-toolset-11 \
                xmlto \
                asciidoc \
                docbook2X \
                gdbm-devel gdbm -y
COPY --from=ebrown/python:3.11 /opt/python /opt/python
ENV LD_LIBRARY_PATH=/opt/python/py311/lib:${LD_LIBRARY_PATH}
ENV PATH=/opt/python/py311/bin:${PATH}
WORKDIR /tmp/bxgboost
RUN wget https://github.com/dmlc/xgboost/releases/download/v1.7.5/xgboost.tar.gz
RUN tar -xf xgboost.tar.gz
WORKDIR /tmp/bxgboost/xgboost
RUN mkdir build
WORKDIR /tmp/bxgboost/xgboost/build
RUN source scl_source enable gcc-toolset-11 && cmake .. -DUSE_CUDA=ON -DBUILD_WITH_CUDA_CUB=ON
RUN source scl_source enable gcc-toolset-11 && make -j 8
WORKDIR /tmp/bxgboost/xgboost/python-package
RUN python3 setup.py bdist_wheel 