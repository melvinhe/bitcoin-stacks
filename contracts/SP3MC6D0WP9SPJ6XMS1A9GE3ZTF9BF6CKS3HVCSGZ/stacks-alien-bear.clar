;; stacks-alien-bear

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stacks-alien-bear uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-NOT-ENOUGH-PASSES u101)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
(define-constant ERR-CONTRACT-INITIALIZED u103)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-AIRDROP-CALLED u112)
(define-constant ERR-NO-MORE-MINTS u113)

;; Internal variables
(define-data-var mint-limit uint u496)
(define-data-var last-id uint u1)
(define-data-var total-price uint u6000000)
(define-data-var artist-address principal 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmVR1xpD99t7xdsKN9MA3XeDuDQtcm2EdsW3Yt887AjGJD/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-twentyfive) (mint (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err ERR-NO-MORE-MINTS))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq (var-get total-price) u0000000))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? stacks-alien-bear next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (toggle-pause)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? stacks-alien-bear token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stacks-alien-bear token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacks-alien-bear token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Non-custodial marketplace extras
(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? stacks-alien-bear id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
          (map-set token-count
            sender
            (- sender-balance u1))
          (map-set token-count
            recipient
            (+ recipient-balance u1))
          (ok success))
    error (err error)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? stacks-alien-bear id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? stacks-alien-bear id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u0) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u1) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u2) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u3) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u4) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u5) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u6) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u7) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u8) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u9) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u10) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u11) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u12) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u13) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u14) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u15) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u16) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u17) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u18) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u19) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u20) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u21) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u22) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u23) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u24) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u25) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u26) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u27) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u28) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u29) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u30) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u31) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u32) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u33) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u34) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u35) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u36) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u37) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u38) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u39) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u40) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u41) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u42) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u43) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u44) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u45) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u46) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u47) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u48) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u49) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u50) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u51) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u52) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u53) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u54) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u55) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u56) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u57) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u58) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u59) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u60) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u61) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u62) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u63) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u64) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u65) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u66) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u67) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u68) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u69) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u70) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u71) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u72) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u73) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u74) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u75) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u76) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u77) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u78) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u79) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u80) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u81) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u82) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u83) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u84) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u85) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u86) 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ))
      (map-set token-count 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ (+ (get-balance 'SP3MC6D0WP9SPJ6XMS1A9GE3ZTF9BF6CKS3HVCSGZ) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u87) 'SP1NT7AHAPCD4JR3DY3MKEJZ2B57ZX2TSEDKF9MN4))
      (map-set token-count 'SP1NT7AHAPCD4JR3DY3MKEJZ2B57ZX2TSEDKF9MN4 (+ (get-balance 'SP1NT7AHAPCD4JR3DY3MKEJZ2B57ZX2TSEDKF9MN4) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u88) 'SP28C6S7YFDSAV2BXKYVKTN2JJ69BGFCSX8RHCMZG))
      (map-set token-count 'SP28C6S7YFDSAV2BXKYVKTN2JJ69BGFCSX8RHCMZG (+ (get-balance 'SP28C6S7YFDSAV2BXKYVKTN2JJ69BGFCSX8RHCMZG) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u89) 'SPJ52DQFJVJACKHY0QX5DRE559MBCXWTSGNBN76V))
      (map-set token-count 'SPJ52DQFJVJACKHY0QX5DRE559MBCXWTSGNBN76V (+ (get-balance 'SPJ52DQFJVJACKHY0QX5DRE559MBCXWTSGNBN76V) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u90) 'SP1PCEAP62X5BZSMH257ZHAPGAPSX3BDT3TDVCN4M))
      (map-set token-count 'SP1PCEAP62X5BZSMH257ZHAPGAPSX3BDT3TDVCN4M (+ (get-balance 'SP1PCEAP62X5BZSMH257ZHAPGAPSX3BDT3TDVCN4M) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u91) 'SP1EPBKHN6PTKE53R1RSDJ8FH531CTNZYRQC33X1E))
      (map-set token-count 'SP1EPBKHN6PTKE53R1RSDJ8FH531CTNZYRQC33X1E (+ (get-balance 'SP1EPBKHN6PTKE53R1RSDJ8FH531CTNZYRQC33X1E) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u92) 'SP48N9CPE2KQZQYH64GZ4FPJWJMGTRPJQWMC5RH7))
      (map-set token-count 'SP48N9CPE2KQZQYH64GZ4FPJWJMGTRPJQWMC5RH7 (+ (get-balance 'SP48N9CPE2KQZQYH64GZ4FPJWJMGTRPJQWMC5RH7) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u93) 'SP2FSBC7GAWR623XQ3QMA9VCFVS4AYTXTZTRWZAJG))
      (map-set token-count 'SP2FSBC7GAWR623XQ3QMA9VCFVS4AYTXTZTRWZAJG (+ (get-balance 'SP2FSBC7GAWR623XQ3QMA9VCFVS4AYTXTZTRWZAJG) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u94) 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS))
      (map-set token-count 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS (+ (get-balance 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u95) 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG))
      (map-set token-count 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG (+ (get-balance 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u96) 'SP33N5R751MG99QAM4CN6HQ3MDTYBR71SB4NXVGT1))
      (map-set token-count 'SP33N5R751MG99QAM4CN6HQ3MDTYBR71SB4NXVGT1 (+ (get-balance 'SP33N5R751MG99QAM4CN6HQ3MDTYBR71SB4NXVGT1) u1))
      (try! (nft-mint? stacks-alien-bear (+ last-nft-id u97) 'SP16PPSNDG265N42ZG7GPDADAAAMQCDY9MT6TN4XY))
      (map-set token-count 'SP16PPSNDG265N42ZG7GPDADAAAMQCDY9MT6TN4XY (+ (get-balance 'SP16PPSNDG265N42ZG7GPDADAAAMQCDY9MT6TN4XY) u1))

      (var-set last-id (+ last-nft-id u98))
      (var-set airdrop-called true)
      (ok true))))