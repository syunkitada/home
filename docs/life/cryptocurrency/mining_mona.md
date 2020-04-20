# Monaの掘り方


## ウォレット・アドレスの準備
* bitflyerなどの取引所でアドレスを作成する
    * このアドレスを掘るときに利用する


## 環境準備
* 環境は、Ubuntu16、GPX1060
* dockerのインストール(公式を参照)
* cudaのインストール
```
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo apt update
sudo apt install cuda cuda-drivers

sudo reboot
```
* nvidia-dockerのインストール
```
$ wget https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
$ sudo dpkg -i nvidia-docker_1.0.1-1_amd64.deb
```


## Dockerfileイメージの作成
```
$ cat Dockerfile
FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

RUN apt-get upgrade && apt-get update
RUN apt-get install -y --no-install-recommends \
    sudo ssh \
    screen cmake unzip git curl wget vim tree htop \
    build-essential \
    cmake pkg-config \
    libgtk2.0-dev pkg-config\
    automake libssl-dev libcurl4-nss-dev

RUN groupadd -g 1942 ubuntu
RUN useradd -m -u 1942 -g 1942 -d /home/ubuntu ubuntu
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu
ENV HOME /home/ubuntu

RUN echo 'CUDA=/usr/local/cuda' >> $HOME/.bashrc
RUN echo 'export PATH=$PATH:$CUDA/bin' >> $HOME/.bashrc

RUN git -c http.sslVerify=false clone https://github.com/tpruvot/ccminer
RUN cd ccminer && \
    ./build.sh


$ sudo nvidia-docker build -t mona ./
```

## 以下を実行してマイニング開始
```
$ sudo nvidia-docker run -ti --rm mona \
  /bin/bash -c "cd /home/ubuntu/ccminer; ./ccminer -a lyra2v2 -o stratum+tcp://{pool_address}:{port} -u {Weblogin.WorkerName} -p {WorkerPassword} "
```


## 補足: プールについて
* プールにユーザ登録して、ワーカーの名前とパスワードを設定する必要があります
* また、ウォレットのアドレスも登録し、掘ったコインを自動で送るように設定できます
* プールは以下から探します(ある程度の規模であれば採掘効率は同じらしい)
    * http://hattenba.xyz/monarate.html
