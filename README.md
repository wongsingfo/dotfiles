# Dockerize the Dotfiles

Tired of endless configuration when setting up a new dev machine? This guide
shows you how to leverage Docker to create a portable, reproducible development
environment. With a single command, you can bring up your customized setup,
complete with dotfiles, dependencies, and GPU support.

## Build the Image

If you're behind a corporate or local proxy, ensure Docker can access external
resources.

Create `/etc/systemd/system/docker.service.d/http-proxy.conf` with the following content:

```
[Service]
Environment="ALL_PROXY=http://172.17.0.1:7890"
```

Remeber to restart the docker:

```
systemctl daemon-reload
systemctl restart docker
```

Ref: https://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy

Include the `build-arg` for the proxy during the build:

```
docker build -t dev -f base-ubuntu.Dockerfile \
    --build-arg ALL_PROXY="http://172.17.0.1:7890" --build-arg HTTPS_PROXY="http://172.17.0.1:7890"\
    .
```

## Run the Container

Once the image is built, you can run your development container:

```
docker run -v $HOME:/work -v $HOME/.ssh:/home/ubuntu/.ssh \
    --cap-add=SYS_ADMIN --security-opt seccomp=unconfined \
    --network host -itd \
    --runtime=nvidia --gpus all \
    --name box dev
```

Explanation of Flags:
- `-v $HOME:/work`: Mounts your host's home directory to `/work` inside the
container. This is crucial for accessing your project files.
- `-v $HOME/.ssh:/home/ubuntu/.ssh`: Mounts your SSH keys for seamless Git and
remote access within the container.
- `--cap-add=SYS_ADMIN --security-opt seccomp=unconfined`: Provides necessary
capabilities for certain operations, often required for tools that modify the
system (e.g., some language environment managers).
- *Ref: [Stack Overflow](https://stackoverflow.com/questions/35860527/warning-error-disabling-address-space-randomization-operation-not-permitted)*
- `--network host`: Uses the host's network stack, allowing the container to
access network services on the host directly and vice-versa.
- `-itd`: Runs the container in interactive (`-i`), pseudo-TTY (`-t`), and
detached (`-d`) modes.
- `--runtime=nvidia --gpus all`: Enables NVIDIA GPU support, allowing the
container to access all available GPUs.
- `--name box`: Assigns the name `box` to your container for easy
identification.
- `dev`: The name of the Docker image to use.

Use the following to attach to the container:

```
docker exec --detach-keys='ctrl-x,e' -it box fish
```

Explanation of Flags:
- `--detach-keys='ctrl-x,e'`: Changes the Docker detach key sequence to
`Ctrl-X, E` to avoid conflicts with common terminal shortcuts (like `Ctrl-P`).

## Using Docker with GPU Support

To leverage the power of your GPU within Docker containers, you need to install
the NVIDIA Container Toolkit. This toolkit allows you to seamlessly run
GPU-accelerated applications inside containers.

### Installation

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

Solution: Modify the NVIDIA config file
`/etc/nvidia-container-runtime/config.toml`, and set `no-cgroups = true`.

Ref: https://stackoverflow.com/questions/77051751/unable-to-run-nvidia-gpu-enabled-docker-containers-inside-an-lxc-container

# Manage Packages with Micromamba (Deprecated)

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
