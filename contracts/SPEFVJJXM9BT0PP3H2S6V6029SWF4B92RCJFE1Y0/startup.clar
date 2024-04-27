(try! (contract-call? .laser_token set_nft_contract .laser_eyes))

;; import former data: https://explorer.stacks.co/txid/SPEFVJJXM9BT0PP3H2S6V6029SWF4B92RCJFE1Y0.laser-eyes?chain=mainnet
(try! (contract-call? .laser_eyes real_mint 0x5361746f736869204e616b616d6f746f 0x5361746f736869 "QmTpU8fpbmTuFe131CMXyBSVmkLM8t2c1rV4ZuYuKbfnDT" 0x5468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73 'SP1F5WP2W6RZBR3AP52A82RV81MB194ESTDBZY6XJ u35058))
(try! (contract-call? .laser_eyes real_mint 0x58 0x "QmZUzx4AG6AyFbDTz8K87vpL5z8xB3LpJ5sACYoQbwMyrj" 0x576520646f6e277420657869737420617420616c6c2e 'SP2S3EAXSRJBVQ1GQSKTM1D14C1ED8KG9H43KF0FC u35117))
(try! (contract-call? .laser_eyes real_mint 0x626f6f6273 0x "QmSHeRByi4JkoHUksgVMd4GmhuEwYzuoGbq18azWPuwNvf" 0x626f6f62732078206879706572696e666c6174696f6e3a2061206d61746368206d61646520696e2068656176656e 'SP3QQZQF09GA87CYRFZPZP13N9PCECWMHEACX44YJ u35126))
(try! (contract-call? .laser_eyes real_mint 0x53545820444f4745 0x "QmcTE9xXeE5agLPEL8oWXwqUKH5RQRRhLFMA7yR2hU2jjg" 0x53545820706c617973206665746368207769746820426974636f696e 'SP3JCJYVVZVY7Y64JYJ57JFS6FM7ASHX6QDTKFXGY u35157))

(try! (contract-call? .laser_eyes set_market_contract .laser_eyes_market))
