# Cipher
## Author: MeHungr (Dylan Weber)

Cipher is an OpenSSH Portable backdoor that allows authentication using a specific password or generated SSH private key. The password is configurable in `auth-universal.h`.

## Installation
1. Configure password in `install/generate_key.sh`
2. Run `install/install.sh` or `install/install-silent.sh` for less noisy output
- This will set up the ssh key and build the executables
3. Output will be in `<project-root>/output`
4. The server executable is `output/sbin/sshd`
