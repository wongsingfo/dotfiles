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
docker run -it -v $(pwd):/work -v $HOME/.ssh:/home/ubuntu/.ssh --name box wongsingfo/dotfiles
```

To detach from the container, use the default key combination: Ctrl-P followed
by Ctrl-Q.

If you need to re-enter the container, execute the following:

```
# We change the detach keys to avoid the confliction with the `Previous` command in the shell
docker start -i --detach-keys='ctrl-z,e' box
```

## Troubleshhot

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


