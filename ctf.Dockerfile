FROM wongsingfo/dotfiles:amd64

RUN sudo apt-get update && sudo apt-get install -y \
	gdb \
	gdbserver \
	&& sudo rm -rf /var/lib/apt/lists/* && \
	python3 -m venv /home/ubuntu/venv && \
	/home/ubuntu/venv/bin/pip install -U \
	patchelf \
	pwntools \
	z3-solver \
