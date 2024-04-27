(define-private (read-uint-closure (idx uint) (state { acc: uint, offset: uint, data: (buff 64)}))
    (let (
            (acc (get acc state))
            (data (get data state))
            (offset (get offset state))
            (byte (buff-to-u8 (unwrap-panic (element-at data (+ idx offset))))))
    
        ;; acc = byte * (2**(8 * (15 - idx))) + acc
        (merge state { acc: (+ (* byte (pow u2 (* u8 (- u15 idx)))) acc)})))


(define-private (read-uint (data (buff 64)) (offset uint))
    (get acc
        (fold read-uint-closure (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15) { acc: u0, data: data, offset: offset})))




(define-private (read-buff32-closure (idx uint) (state { offset: uint, data: (buff 64), acc: (buff 32)}))
    (let (
        (byte-data (unwrap-panic (element-at (get data state) (+ idx (get offset state))))))
    
        (merge state { acc: (unwrap-panic (as-max-len? (concat (get acc state) byte-data) u32))})))

(define-private (read-buff32 (data (buff 64)) (offset uint))
    (get acc
        (fold read-buff32-closure
            (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31)
            { offset: offset, data: data, acc: 0x})))



(define-private (merkle-proof-root-closure (idx uint) (state { acc: (buff 32), acc-index: uint, hashes: (list 32 (buff 32))}))
    (if (< idx (len (get hashes state)))
        (let (
            (acc-index (get acc-index state))
            (ith-hash (unwrap-panic (element-at (get hashes state) idx)))
            (ith-bit (mod acc-index u2))
            (next-acc
                (if (is-eq ith-bit u0)
                    (sha512/256 (concat (get acc state) ith-hash))
                    (sha512/256 (concat ith-hash (get acc state)))))

            (next-acc-index (/ acc-index u2)))

            (merge state { acc: next-acc, acc-index: next-acc-index}))

        state))

;; compute the merkle root of a merkle proof
(define-read-only (merkle-proof-root (nft-desc (buff 64)) (proof { hashes: (list 32 (buff 32)), index: uint}))
    (get acc
        (fold merkle-proof-root-closure
            (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31)
            { acc: (sha512/256 nft-desc), acc-index: (get index proof), hashes: (get hashes proof)})))



(define-constant BUFF_TO_BYTE (list 
                                0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
                                0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
                                0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
                                0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
                                0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
                                0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
                                0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
                                0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
                                0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
                                0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
                                0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
                                0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
                                0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
                                0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
                                0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
                                0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff))



(define-private (buff-to-u8 (byte (buff 1)))
    (unwrap-panic (index-of BUFF_TO_BYTE byte)))
