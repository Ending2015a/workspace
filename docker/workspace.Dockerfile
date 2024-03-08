ARG BASE_IMAGE=nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04

FROM $BASE_IMAGE AS base

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential \
    git curl cmake autoconf automake libtool vim ca-certificates \
    libjpeg-dev libpng-dev libglfw3-dev libglm-dev libx11-dev libomp-dev \
    libegl1-mesa-dev pkg-config ffmpeg wget zip unzip g++ gcc python3-pip \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r /tmp/requirements.txt --no-cache-dir


CMD "/bin/bash"
