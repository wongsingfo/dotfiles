# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture
This is a dotfiles repository for managing a portable, reproducible development environment across Linux and macOS, with Docker container support.

### Core Structure
- **`stow-dotfiles/`**: Dotfiles organized per application, managed via GNU Stow. Each subdirectory contains configuration for a specific tool that will be symlinked to the user's home directory:
  alacritty, claude, claude-code-router, fish, git, kitty, llm, nvim, opencode, ranger, tmux, yazi, zathura.
- **`docker/`**: Dockerfiles for building containerized development environments:
  - `base-ubuntu.Dockerfile`: Primary development image with all tools pre-installed
  - `base-tlinux.Dockerfile`: Tencent Linux base image
  - `ctf.Dockerfile`: CTF competition environment
  - `rust.Dockerfile`: Rust development image
- **`vibe-coding/`**: Resources for AI-assisted development.
- **Setup scripts**: `setup_linux.sh` and `setup_macos.sh` for bootstrapping new development machines.

## Common Commands

### Environment Setup
- **Linux setup**: `./setup_linux.sh [--install-rust]`
  Installs system packages, development tools (Fish shell, Neovim, tmux, fzf, fd, zoxide, uv, etc.), and stows all dotfiles. Add `--install-rust` to include the Rust toolchain.
- **macOS setup**: `./setup_macos.sh [--install-rust]`
  Same as Linux setup, uses Homebrew for package management.

### Dotfile Management
- **Stow all dotfiles**:
  ```bash
  cd stow-dotfiles && stow -t "$HOME" -R */
  ```
- **Stow a specific application's dotfiles**:
  ```bash
  cd stow-dotfiles && stow -t "$HOME" -R <app-name>
  ```
  Example: `stow -t "$HOME" -R nvim` to update Neovim configuration.

### Fixing Config Issues

Configuration changes often work as expected on one machine or operating system but break on others due to cross-platform differences. When reproducing problem and addressing broken configuration, use a new, isolated tmux session to reproduce and verify your fix (take care not to terminate existing user tmux sessions)
