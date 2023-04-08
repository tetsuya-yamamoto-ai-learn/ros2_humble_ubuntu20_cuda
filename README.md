# Docker Ubuntu 20.04LTS ROS2 Humble CUDA 11.3.1 CUNDD 8

## BUILD

    docker-compose build

## RUN

- コンテナの起動

    docker-compose run ros-humble-ubuntu20

- GUIを使用する場合はホスト環境で以下のコマンドを実行してlocalからのアクセスのみ、xhostへのアクセスを許可する

    アクセス許可時：
    
        xhost +local:

    アクセス停止：

        xhost -local:

