FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04

# install sudo for cuda gui
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# setting locale
RUN apt update && apt install locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# set timezone
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# add the ros2 apt repository
RUN apt install software-properties-common -y
RUN add-apt-repository universe -y
RUN apt update && apt install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# install development tools and ros tools
RUN apt update && apt install -y \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest-cov \
  ros-dev-tools

# install python packages
RUN python3 -m pip install -U \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-import-order \
    flake8-quotes \
    "pytest>=5.3" \
    pytest-repeat \
    pytest-rerunfailures

# Get ROS2 code
RUN mkdir -p /opt/ros2_humble/src && \
    cd /opt/ros2_humble && \
    vcs import --input https://raw.githubusercontent.com/ros2/ros2/humble/ros2.repos src

# install dependencies using rosdep
RUN apt upgrade -y && \
    rosdep init && \
    rosdep update && \
    cd /opt/ros2_humble && \
    rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

# get ros2 cvBridge code
RUN apt install python3-numpy libboost-python-dev python3-opencv -y
RUN cd /opt/ros2_humble/src && \
    git clone https://github.com/ros-perception/vision_opencv.git

# build the ros2 code
RUN cd /opt/ros2_humble/ && \
    colcon build --symlink-install

# setup ros2
RUN echo "source /opt/ros2_humble/install/setup.bash" >> ~/.bashrc

# for pcd
RUN pip install open3d
RUN pip install --upgrade numpy