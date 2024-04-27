;; haloxylon-ammodendron-v
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token haloxylon-ammodendron-v uint)

(define-constant DEPLOYER tx-sender)

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-INVALID-PERCENTAGE u114)

(define-data-var last-id uint u0)
(define-data-var artist-address principal 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF)
(define-data-var locked bool false)
(define-data-var metadata-frozen bool false)

(define-map cids uint (string-ascii 64))

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market token-id)) (err ERR-LISTING))
    (nft-burn? haloxylon-ammodendron-v token-id tx-sender)))

(define-public (set-token-uri (hash (string-ascii 64)) (token-id uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (print { notification: "token-metadata-update", payload: { token-class: "nft", token-ids: (list token-id), contract-id: (as-contract tx-sender) }})
    (map-set cids token-id hash)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? haloxylon-ammodendron-v token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? haloxylon-ammodendron-v token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat "ipfs://" (unwrap-panic (map-get? cids token-id))))))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-public (claim (uris (list 25 (string-ascii 64))))
  (mint-many uris))

(define-private (mint-many (uris (list 25 (string-ascii 64))))
  (let 
    (
      (token-id (+ (var-get last-id) u1))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter uris token-id))
      (current-balance (get-balance tx-sender))
    )
    (asserts! (or (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
    (var-set last-id (- id-reached u1))
    (map-set token-count tx-sender (+ current-balance (- id-reached token-id)))    
    (ok id-reached)))

(define-private (mint-many-iter (hash (string-ascii 64)) (next-id uint))
  (begin
    (unwrap! (nft-mint? haloxylon-ammodendron-v next-id tx-sender) next-id)
    (map-set cids next-id hash)      
    (+ next-id u1)))

;; NON-CUSTODIAL FUNCTIONS START
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? haloxylon-ammodendron-v id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? haloxylon-ammodendron-v id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
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
  (let ((owner (unwrap! (nft-get-owner? haloxylon-ammodendron-v id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))
    
(define-data-var royalty-percent uint u500)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (and (> royalty-amount u0) (not (is-eq tx-sender (var-get artist-address))))
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))

;; NON-CUSTODIAL FUNCTIONS END

(try! (nft-mint? haloxylon-ammodendron-v u1 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u1 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/1.json")
(try! (nft-mint? haloxylon-ammodendron-v u2 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u2 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/2.json")
(try! (nft-mint? haloxylon-ammodendron-v u3 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u3 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/3.json")
(try! (nft-mint? haloxylon-ammodendron-v u4 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u4 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/4.json")
(try! (nft-mint? haloxylon-ammodendron-v u5 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u5 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/5.json")
(try! (nft-mint? haloxylon-ammodendron-v u6 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u6 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/6.json")
(try! (nft-mint? haloxylon-ammodendron-v u7 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u7 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/7.json")
(try! (nft-mint? haloxylon-ammodendron-v u8 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u8 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/8.json")
(try! (nft-mint? haloxylon-ammodendron-v u9 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u9 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/9.json")
(try! (nft-mint? haloxylon-ammodendron-v u10 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u10 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/10.json")
(try! (nft-mint? haloxylon-ammodendron-v u11 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u11 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/11.json")
(try! (nft-mint? haloxylon-ammodendron-v u12 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u12 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/12.json")
(try! (nft-mint? haloxylon-ammodendron-v u13 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u13 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/13.json")
(try! (nft-mint? haloxylon-ammodendron-v u14 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u14 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/14.json")
(try! (nft-mint? haloxylon-ammodendron-v u15 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u15 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/15.json")
(try! (nft-mint? haloxylon-ammodendron-v u16 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u16 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/16.json")
(try! (nft-mint? haloxylon-ammodendron-v u17 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u17 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/17.json")
(try! (nft-mint? haloxylon-ammodendron-v u18 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u18 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/18.json")
(try! (nft-mint? haloxylon-ammodendron-v u19 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u19 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/19.json")
(try! (nft-mint? haloxylon-ammodendron-v u20 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u20 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/20.json")
(try! (nft-mint? haloxylon-ammodendron-v u21 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u21 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/21.json")
(try! (nft-mint? haloxylon-ammodendron-v u22 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u22 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/22.json")
(try! (nft-mint? haloxylon-ammodendron-v u23 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u23 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/23.json")
(try! (nft-mint? haloxylon-ammodendron-v u24 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u24 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/24.json")
(try! (nft-mint? haloxylon-ammodendron-v u25 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u25 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/25.json")
(try! (nft-mint? haloxylon-ammodendron-v u26 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u26 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/26.json")
(try! (nft-mint? haloxylon-ammodendron-v u27 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u27 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/27.json")
(try! (nft-mint? haloxylon-ammodendron-v u28 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u28 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/28.json")
(try! (nft-mint? haloxylon-ammodendron-v u29 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u29 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/29.json")
(try! (nft-mint? haloxylon-ammodendron-v u30 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u30 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/30.json")
(try! (nft-mint? haloxylon-ammodendron-v u31 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u31 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/31.json")
(try! (nft-mint? haloxylon-ammodendron-v u32 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u32 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/32.json")
(try! (nft-mint? haloxylon-ammodendron-v u33 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u33 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/33.json")
(try! (nft-mint? haloxylon-ammodendron-v u34 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u34 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/34.json")
(try! (nft-mint? haloxylon-ammodendron-v u35 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u35 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/35.json")
(try! (nft-mint? haloxylon-ammodendron-v u36 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u36 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/36.json")
(try! (nft-mint? haloxylon-ammodendron-v u37 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u37 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/37.json")
(try! (nft-mint? haloxylon-ammodendron-v u38 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u38 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/38.json")
(try! (nft-mint? haloxylon-ammodendron-v u39 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u39 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/39.json")
(try! (nft-mint? haloxylon-ammodendron-v u40 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u40 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/40.json")
(try! (nft-mint? haloxylon-ammodendron-v u41 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u41 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/41.json")
(try! (nft-mint? haloxylon-ammodendron-v u42 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u42 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/42.json")
(try! (nft-mint? haloxylon-ammodendron-v u43 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u43 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/43.json")
(try! (nft-mint? haloxylon-ammodendron-v u44 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u44 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/44.json")
(try! (nft-mint? haloxylon-ammodendron-v u45 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u45 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/45.json")
(try! (nft-mint? haloxylon-ammodendron-v u46 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u46 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/46.json")
(try! (nft-mint? haloxylon-ammodendron-v u47 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u47 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/47.json")
(try! (nft-mint? haloxylon-ammodendron-v u48 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u48 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/48.json")
(try! (nft-mint? haloxylon-ammodendron-v u49 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u49 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/49.json")
(try! (nft-mint? haloxylon-ammodendron-v u50 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u50 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/50.json")
(try! (nft-mint? haloxylon-ammodendron-v u51 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u51 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/51.json")
(try! (nft-mint? haloxylon-ammodendron-v u52 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u52 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/52.json")
(try! (nft-mint? haloxylon-ammodendron-v u53 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u53 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/53.json")
(try! (nft-mint? haloxylon-ammodendron-v u54 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u54 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/54.json")
(try! (nft-mint? haloxylon-ammodendron-v u55 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u55 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/55.json")
(try! (nft-mint? haloxylon-ammodendron-v u56 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u56 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/56.json")
(try! (nft-mint? haloxylon-ammodendron-v u57 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u57 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/57.json")
(try! (nft-mint? haloxylon-ammodendron-v u58 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u58 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/58.json")
(try! (nft-mint? haloxylon-ammodendron-v u59 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u59 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/59.json")
(try! (nft-mint? haloxylon-ammodendron-v u60 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u60 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/60.json")
(try! (nft-mint? haloxylon-ammodendron-v u61 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u61 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/61.json")
(try! (nft-mint? haloxylon-ammodendron-v u62 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u62 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/62.json")
(try! (nft-mint? haloxylon-ammodendron-v u63 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u63 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/63.json")
(try! (nft-mint? haloxylon-ammodendron-v u64 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u64 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/64.json")
(try! (nft-mint? haloxylon-ammodendron-v u65 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u65 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/65.json")
(try! (nft-mint? haloxylon-ammodendron-v u66 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u66 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/66.json")
(try! (nft-mint? haloxylon-ammodendron-v u67 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u67 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/67.json")
(try! (nft-mint? haloxylon-ammodendron-v u68 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u68 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/68.json")
(try! (nft-mint? haloxylon-ammodendron-v u69 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u69 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/69.json")
(try! (nft-mint? haloxylon-ammodendron-v u70 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u70 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/70.json")
(try! (nft-mint? haloxylon-ammodendron-v u71 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u71 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/71.json")
(try! (nft-mint? haloxylon-ammodendron-v u72 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u72 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/72.json")
(try! (nft-mint? haloxylon-ammodendron-v u73 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u73 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/73.json")
(try! (nft-mint? haloxylon-ammodendron-v u74 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u74 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/74.json")
(try! (nft-mint? haloxylon-ammodendron-v u75 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u75 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/75.json")
(try! (nft-mint? haloxylon-ammodendron-v u76 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u76 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/76.json")
(try! (nft-mint? haloxylon-ammodendron-v u77 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u77 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/77.json")
(try! (nft-mint? haloxylon-ammodendron-v u78 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u78 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/78.json")
(try! (nft-mint? haloxylon-ammodendron-v u79 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u79 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/79.json")
(try! (nft-mint? haloxylon-ammodendron-v u80 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u80 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/80.json")
(try! (nft-mint? haloxylon-ammodendron-v u81 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u81 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/81.json")
(try! (nft-mint? haloxylon-ammodendron-v u82 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u82 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/82.json")
(try! (nft-mint? haloxylon-ammodendron-v u83 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF))
(map-set token-count 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF (+ (get-balance 'SP2RYWNM8VWM2M7VG9W5SR5S617CD3Y091PCQGHBF) u1))
(map-set cids u83 "QmQFg8HjRv8ZpkbSSvPN4d89B3cmV8Y94KkbaM9rk1G51p/json/83.json")
(var-set last-id u83)

(define-data-var license-uri (string-ascii 80) "")
(define-data-var license-name (string-ascii 40) "")

(define-read-only (get-license-uri)
  (ok (var-get license-uri)))
  
(define-read-only (get-license-name)
  (ok (var-get license-name)))
  
(define-public (set-license-uri (uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-uri uri))))
    
(define-public (set-license-name (name (string-ascii 40)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-name name))))