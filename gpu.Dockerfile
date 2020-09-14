ARG  TAG_VERSION
FROM tensorflow/tensorflow:${TAG_VERSION}
MAINTAINER kbogdan

# https://askubuntu.com/a/1013396
ARG DEBIAN_FRONTEND=noninteractive
ARG LOCAL

ENV NUM_CORES 8

WORKDIR /

# Install requirements for OpenCV and other packages
RUN apt-get -y update -qq && \
    apt-get -y install wget \
                       unzip \
                       # Required
                       build-essential \
                       cmake \
                       git \
                       pkg-config \
                       libatlas-base-dev \
                       libgtk2.0-dev \
                       libavcodec-dev \
                       libavformat-dev \
                       libswscale-dev \
                       nano \
                       yasm \
                       # Optional
                       libtbb2 libtbb-dev \
                       libjpeg-dev \
                       libpng-dev \
                       libtiff-dev \
                       libv4l-dev \
                       libdc1394-22-dev \
                       python3-tk \
                       vim \
                       default-jre  # Java

# Get OpenCV
# If installing a specific version is need add 'git checkout $OPENCV_VERSION'
# after clonning and running the "cd" command
RUN git clone https://github.com/opencv/opencv.git &&\
    cd opencv &&\
    cd / &&\
    # Get OpenCV contrib modules
    git clone https://github.com/opencv/opencv_contrib &&\
    cd opencv_contrib &&\
    mkdir /opencv/build &&\
    cd /opencv/build &&\

    # Lets build OpenCV
    cmake \
      -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D INSTALL_C_EXAMPLES=OFF \
      -D INSTALL_PYTHON_EXAMPLES=OFF \
      -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
      -D BUILD_EXAMPLES=OFF \
      -D BUILD_NEW_PYTHON_SUPPORT=ON \
      -D BUILD_DOCS=OFF \
      -D BUILD_TESTS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D WITH_TBB=ON \
      -D WITH_OPENMP=ON \
      -D WITH_IPP=ON \
      -D WITH_CSTRIPES=ON \
      -D WITH_OPENCL=ON \
      -D WITH_V4L=ON \
      .. &&\
    make -j$NUM_CORES &&\
    make install &&\
    ldconfig &&\

    # Clean the install from sources
    cd / &&\
    rm -r /opencv &&\
    rm -r /opencv_contrib

WORKDIR /
# ==================================================


# Install ffmpeg # =================================
# First install nvidia headers, now they use a separate repository for this
WORKDIR /tmp/ffmpeg-codec

RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /tmp/ffmpeg-codec && \
    cd /tmp/ffmpeg-codec && \
    make && \
    make install

WORKDIR /
WORKDIR /tmp/ffmpeg

# Removing --enable-libnpp, is generating an error. Original line: (--enable-cuvid  --enable-libnpp)
# probably will need an instalation of CUDA SDK
# https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/9.1/runtime/Dockerfile
# https://trac.ffmpeg.org/ticket/6405

# Compile and install ffmpeg from source
RUN git clone https://github.com/FFmpeg/FFmpeg /tmp/ffmpeg && \
  cd /tmp/ffmpeg && ./configure \
  --enable-nonfree \
  --disable-shared \
  --enable-nvenc \
  --enable-cuda \
  --enable-cuvid  \
  --extra-cflags=-I/usr/local/cuda/include \
  --extra-cflags=-I/usr/local/include \
  --extra-ldflags=-L/usr/local/cuda/lib64 && \
  make -j$NUM_CORES && \
  make install -j$NUM_CORES && \
  cd /tmp && rm -rf ffmpeg

WORKDIR /
# ===================================================

RUN pip install --upgrade pip

# Install requirements
COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt

# =======================================================================

# Cleaning temporary files and others
RUN apt-get autoclean autoremove &&\
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

# User related arguments to be passed to the image
ARG UID
ARG GID
ARG USER_NAME
ARG GROUP

RUN echo $UID
RUN echo $GID
RUN echo $USER_NAME
RUN echo $GROUP

# Adds the user information to the image
RUN   groupadd --gid $GID $GROUP && \
      useradd --create-home --shell /bin/bash --uid $UID --gid $GID $USER_NAME && \
      adduser $USER_NAME sudo && \
      su -l $USER
USER $USER_NAME


CMD ["/bin/bash"]
