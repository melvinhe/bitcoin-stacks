(define-constant sender 'SP16MYYYH4Z51EAS76K55JMJ182629JNWSHK5NWM)
(define-constant recipient 'SP1VG2RCJ5E8R79SG5G7GPZGM30CZQRD8QDJNAZTS)

(define-non-fungible-token soconftstacks11 uint)
(nft-mint? soconftstacks11 u1 sender)
(nft-mint? soconftstacks11 u2 sender)
(nft-transfer? soconftstacks11 u1 sender recipient)

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://ipfs.io/ipfs/bafybeidexzy3wune4rwcx6amypwq52v26gal5luugtmxmtu3p4eqjv7v4i/socomd.json")))