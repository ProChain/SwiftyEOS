//
//  libbase58.h
//  SwiftyEOS
//
//  Created by croath on 2018/5/8.
//  Copyright © 2018 ProChain. All rights reserved.
//

#ifndef LIBBASE58_H
#define LIBBASE58_H

#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    extern bool (*b58_sha256_impl)(void *, const void *, size_t);
    
    extern bool se_b58tobin(void *bin, size_t *binsz, const char *b58, size_t b58sz);
    extern int se_b58check(const void *bin, size_t binsz, const char *b58, size_t b58sz);
    
    extern bool se_b58enc(char *b58, size_t *b58sz, const void *bin, size_t binsz);
    extern bool se_b58check_enc(char *b58c, size_t *b58c_sz, uint8_t ver, const void *data, size_t datasz);
    
    extern int base58_encode_check(const uint8_t *data, int datalen, char *str, int strsize);
    extern int base58_decode_check(const char *str, uint8_t *data, int datalen);
    
#ifdef __cplusplus
}
#endif

#endif
