// ios_decryptor.h
#ifndef IOS_DECRYPTOR_H
#define IOS_DECRYPTOR_H

#ifdef __cplusplus
extern "C" {
#endif

// 内容解密
unsigned char* ios_decrypt_buffer(const unsigned char* input, int input_len, int* out_len);

// 2.0版本后一些接口数据解密
unsigned char* ios_decrypt_bytes(const unsigned char* input, int input_len, int* out_len);

#ifdef __cplusplus
}
#endif

#endif // IOS_DECRYPTOR_H
