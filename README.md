# Manage Packages with Micromamba

In situations where root privileges are not available to install required
packages, Micromamba can be a useful tool. Here's a simple guide on how to use
Micromamba to manage packages:

Install with:
```
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

Export the existing environment to a YAML file named `oldenv.yaml` using the
following command:

```
micromamba env export --name oldenv > oldenv.yaml
```

Create a new environment named `newenv` using the exported YAML file
`oldenv.yaml`:

```
micromamba env create --name newenv --file oldenv.yaml
```

# Dockerize the Dotfiles

Have you ever been in a situation where you need to reconfigure your
development environment every time you face a new machine? The relentless cycle
of package installations, dotfile transfers, and occasionally wrestling with
network proxies can be downright maddening. But worry not, we can harnessed the
power of Docker, to deliver a solution that will forever change the way you set
up your development environment. With just one command, you can wave goodbye to
the days of manual configuration.

## Quick Start

First, ensure that you have Docker installed. If you're using the apt package
manager, you can do so with the following command:

```
sudo apt install docker.io
```

Now, you're ready to begin using our Dockerized Dotfiles. Start by running this
command:

```
docker run -it -v $(pwd):/work --name box wongsingfo/dotfiles

# Or also bind the auth files
docker run -it \
    -v $(pwd):/work -v $HOME/.ssh:/home/ubuntu/.ssh \
    -v $HOME/.cache/nvim/codeium/config.json:/home/ubuntu/.cache/nvim/codeium/config.json \
    -v $HOME/.config/OPENAI_API_KEY:/home/ubuntu/.config/OPENAI_API_KEY \
    --name box wongsingfo/dotfiles

# Allow gdb to disable the ASLR
# https://stackoverflow.com/questions/35860527/warning-error-disabling-address-space-randomization-operation-not-permitted
docker run -it \
    --cap-add=SYS_PTRACE --security-opt seccomp=unconfined
    wongsingfo/dotfiles:ctf
```

To detach from the container, use the default key combination: Ctrl-P followed
by Ctrl-Q.

If you need to re-enter the container, execute the following:

```
# We change the detach keys to avoid the confliction with the `Previous` command in the shell
docker start -i --detach-keys='ctrl-x,e' box
```

## Using Docker with GPU Support

To leverage the power of your GPU within Docker containers, you need to install
the NVIDIA Container Toolkit. This toolkit allows you to seamlessly run
GPU-accelerated applications inside containers.

## Installation

Refer to the [official NVIDIA Container Toolkit installation
guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
for full details:

Below is a simplified copy of the essential installation steps:

```sh
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt update

export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
apt-get install -y \
      nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
```

## Running a GPU-Enabled Container

Once the NVIDIA Container Toolkit is installed, you can run containers with GPU
support using the `--gpus all` flag:

```sh
docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

## Troubleshooting

### Permission Issues

If you encounter permission problems, it may be because the container uses the
user ID 1000 by default, and the files under $(pwd) do not belong to this user.
One solution is to modify the user ID of the 'ubuntu' user inside the
container:

```
# Suppose the user ID of the current user is 1004
sudo su -c 'usermod -u 1004 ubuntu && groupmod -g 1004 ubuntu'

# Flush the Fish shell cache
rm -rf /tmp/fish.ubuntu
```

### My Ctrl-P Key Is Not Working

Ctrl-P is the default key binding for the `Previous` command in the shell.
However, it conflicts with the Docker detach key (Ctrl-P + Ctrl-Q). To change
the detach key, change the config file in the `~/.docker/config.json` file.

```json
{
    "detachKeys": "ctrl-x,e"
}
```

### Docker cgroup issues (NVIDIA & LXC)

https://stackoverflow.com/questions/77051751/unable-to-run-nvidia-gpu-enabled-docker-containers-inside-an-lxc-container

Modify the NVIDIA config file `/etc/nvidia-container-runtime/config.toml`, and
set no-cgroups = true.
