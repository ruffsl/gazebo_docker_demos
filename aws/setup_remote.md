# Setting up our AMI
For this setup we'll start with a stock Ubnutu 14.04 LTS AMI.

# Installs

## Tools
Add some helpful tools
```shell
sudo apt-get update
sudo apt-get install -y \
    fish \
    glances \
    byobu \
    wget
```

## Docker
Install experimental docker
```shell
wget -qO- https://experimental.docker.com/ | sh
```
> add user to docker group

```shell
sudo usermod -aG docker ubuntu
```

## Graphics

### Nvidia
Install nvidia driver, here we'll just piggyback off the cuda. More details [here](# http://www.r-tutor.com/gpu-computing/cuda-installation/cuda7.0-ubuntu
).
```shell
export CUDA_DEB_URL=http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.0-28_amd64.deb
export CUDA_DEB=cuda-repo-ubuntu1404_7.0-28_amd64.deb
wget $CUDA_DEB_URL
sudo dpkg -i $CUDA_DEB
sudo apt-get update
sudo apt-get install cuda-7-0
```
> reboot and test drivers and test with `nvidia-smi`. Should look somthing like this:

```shell
nvidia-smi
Thu Jul  9 06:59:14 2015
+------------------------------------------------------+
| NVIDIA-SMI 346.46     Driver Version: 346.46         |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GRID K520           Off  | 0000:00:03.0     Off |                  N/A |
| N/A   29C    P8    17W / 125W |     41MiB /  4095MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID  Type  Process name                               Usage      |
|=============================================================================|
|    0     14999    G   /usr/bin/X                                      22MiB |
|    0     25995    G   gzserver                                         6MiB |
+-----------------------------------------------------------------------------+
```
> Doesn't work? Go down the [rabbit hole](http://tleyden.github.io/blog/2014/10/25/cuda-6-dot-5-on-aws-gpu-instance-running-ubuntu-14-dot-04/) and read the `Disable Nouveau` section, watch the versions though: `sudo apt-get install linux-headers-$(uname -r)`

### X server
Install and setup X display. Snippets taken from cloudsim [setup scripts](https://bitbucket.org/osrf/cloudsim/src/f605c94afd95e0078401ec1130b7c206c69380bc/cloudsimd/launchers/launch_utils/startup_scripts.py?at=default).

```shell
sudo apt-get update
apt-get install -y \
    linux-headers-`uname -r` \
    pciutils \
    lsof \
    gnome-session \
    gnome-session-fallback \
    xserver-xorg-core \
    xserver-xorg \
    mesa-utils \
    lightdm \
    x11-xserver-utils
```
> Have the NVIDIA tools create the xorg configuration file for us, retrieiving the PCI BusID for the current system. The BusID can vary from machine to machine.

```shell
nvidia-xconfig --use-display-device=None --virtual=1280x1024 --busid "nvidia-xconfig --query-gpu-info | grep BusID | head -n 1 | sed 's/PCI BusID : PCI:/PCI:/'"
export DISPLAY=:0
```
> Configure lightdm  

```shell
echo "
[SeatDefaults]
greeter-session=unity-greeter
autologin-user=ubuntu
autologin-user-timeout=0
user-session=gnome-fallback
" > /etc/lightdm/lightdm.conf
```
> Check that lightdm runs

```shell
initctl stop lightdm || true
initctl start lightdm
```
