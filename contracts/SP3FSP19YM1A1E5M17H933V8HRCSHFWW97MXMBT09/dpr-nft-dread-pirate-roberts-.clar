;; dpr-nft-dread-pirate-roberts-

;; testnet
;; (impl-trait 'ST1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XZ54PKG7.nft-trait.nft-trait)
;; mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token dpr-nft-dread-pirate-roberts- uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant err-mint u600)

(define-constant COMM u1000)

(define-constant DEPLOYER tx-sender)
(define-constant COMM_ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

;; Internal variables
(define-data-var mint-limit uint u500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u59000000)
(define-data-var artist-address principal 'SP3FSP19YM1A1E5M17H933V8HRCSHFWW97MXMBT09)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXNCeYvaHRtbmG1mQHpLmnuQw9sieZQrx9cbqtECjZsvR/json/")

(define-private (mint-many (orders (list 10 bool )))  
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err err-no-more-nfts)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (var-set last-id id-reached)
      (begin
        (var-set last-id id-reached)
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM_ADDR))
      )    
    )
    (ok id-reached)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? dpr-nft-dread-pirate-roberts- next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id
  )
)

(define-public (claim) 
  (mint-many (list true))
)

(define-public (claim-five)
  (mint-many (list true true true true true))
)

(define-public (claim-ten)
  (mint-many (list true true true true true true true true true true))
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set artist-address address))
  )
)

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set total-price price))
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err err-invalid-user))
    (nft-transfer? dpr-nft-dread-pirate-roberts- token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? dpr-nft-dread-pirate-roberts- token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))