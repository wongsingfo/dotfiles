# Dotfiles

It's time to create your own dotfiles. [This blog post by Anish Athalye](https://www.anishathalye.com/2014/08/03/managing-your-dotfiles/) demonstates the necessity and fun to tweak and optimize one's own dotfiles.

Dotfiles need to be easy to manage and udpate. Here are some amazing management suites for dotfiles:

- [rcm](https://github.com/thoughtbot/rcm)
- [dotbot](https://github.com/anishathalye/dotbot)

## Learn from Others' Configurations

- https://github.com/anishathalye/dotfiles
- https://github.com/thoughtbot/dotfiles

## Docker

```
sudo apt install docker.io

docker run -it --detach-keys='ctrl-e,e' -v $(pwd):/work --name box wongsingfo/dotfiles
sudo su -c 'usermod -u 1004 ubuntu && groupmod -g 1004 ubuntu'
rm -rf /tmp/fish.ubuntu

docker start -i box
```
