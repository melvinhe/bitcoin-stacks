(try! (contract-call? .laser-token-v4 set_nft_contract .laser-eyes-v4))
(try! (contract-call? .laser-eyes-v4 set_ext_contract .laser-eyes-market-v4))
(try! (contract-call? .laser-eyes-v4 set_ext_contract .laser-eyes-like-v4))

(try! (contract-call? .laser-eyes-v4 mint_for_reborn 0x5361746f736869204e616b616d6f746f 0x5361746f736869 "QmXLf19kGcSSV6tnMA2ydZkGUKWZKAnGkc1YU4vCDsELLJ" 0x5468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73 'SP16KWQY6ZPXNYT43A4RKXBXMFT3V7ZMV5YYNR1CK u35058))
(try! (contract-call? .laser-eyes-v4 mint_for_reborn 0x58 0x "QmZUzx4AG6AyFbDTz8K87vpL5z8xB3LpJ5sACYoQbwMyrj" 0x576520646f6e277420657869737420617420616c6c2e 'SP2S3EAXSRJBVQ1GQSKTM1D14C1ED8KG9H43KF0FC u35117))
(try! (contract-call? .laser-eyes-v4 mint_for_reborn 0x626f6f6273 0x "QmSHeRByi4JkoHUksgVMd4GmhuEwYzuoGbq18azWPuwNvf" 0x626f6f62732078206879706572696e666c6174696f6e3a2061206d61746368206d61646520696e2068656176656e 'SP3QQZQF09GA87CYRFZPZP13N9PCECWMHEACX44YJ u35126))
(try! (contract-call? .laser-eyes-v4 mint_for_reborn 0x53545820444f4745 0x "QmcTE9xXeE5agLPEL8oWXwqUKH5RQRRhLFMA7yR2hU2jjg" 0x53545820706c617973206665746368207769746820426974636f696e 'SP3JCJYVVZVY7Y64JYJ57JFS6FM7ASHX6QDTKFXGY u35157))
(try! (contract-call? .laser-eyes-v4 mint_for_reborn 0x4a61636b20446f727365796573 0x "QmReN4ziCJN6JRHaMcVQZmNn9ZUzaXmptJuAiFYj5QW7VM" 0x49206f7567687420746f2062652063686965662e2e2e626563617573652049276d20636861707465722063686f72697374657220616e64206865616420626f792e20492063616e2073696e67204323 'SP2A24GZ4J61A39QP1T67SQX44FWRHWJXMYJWGP97 u38398))
(try! (contract-call? .laser-eyes-v4 mint_for_reborn 0x52616c7068204a6f6e65732048524820457371 0x "QmT5wmxssgboVrm9BCJYR22DkeQoDndmQEFd3kqASavkp8" 0x4d616320746f6e6967687420636f6e6e6f6973736575722e20456e676167656420746f207072696e63657373206f662044656e6d61726b2062757420686173206c617365722065796573203420796f75 'SPKY69SQZSB999DTPFE8VVZM9W0GYYFJKX5F9SP8 u39823))

(contract-call? .laser-eyes-v4 set_petrify)
