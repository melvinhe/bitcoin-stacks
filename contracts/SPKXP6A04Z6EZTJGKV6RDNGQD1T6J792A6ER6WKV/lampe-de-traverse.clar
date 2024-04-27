;; lampe-de-traverse
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token lampe-de-traverse uint)

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
(define-data-var artist-address principal 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV)
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
    (nft-burn? lampe-de-traverse token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? lampe-de-traverse token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? lampe-de-traverse token-id)))

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
    (unwrap! (nft-mint? lampe-de-traverse next-id tx-sender) next-id)
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
  (match (nft-transfer? lampe-de-traverse id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? lampe-de-traverse id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? lampe-de-traverse id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? lampe-de-traverse u1 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u1 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/1.json")
(try! (nft-mint? lampe-de-traverse u2 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u2 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/2.json")
(try! (nft-mint? lampe-de-traverse u3 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u3 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/3.json")
(try! (nft-mint? lampe-de-traverse u4 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u4 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/4.json")
(try! (nft-mint? lampe-de-traverse u5 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u5 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/5.json")
(try! (nft-mint? lampe-de-traverse u6 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u6 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/6.json")
(try! (nft-mint? lampe-de-traverse u7 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u7 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/7.json")
(try! (nft-mint? lampe-de-traverse u8 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u8 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/8.json")
(try! (nft-mint? lampe-de-traverse u9 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u9 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/9.json")
(try! (nft-mint? lampe-de-traverse u10 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u10 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/10.json")
(try! (nft-mint? lampe-de-traverse u11 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u11 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/11.json")
(try! (nft-mint? lampe-de-traverse u12 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u12 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/12.json")
(try! (nft-mint? lampe-de-traverse u13 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u13 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/13.json")
(try! (nft-mint? lampe-de-traverse u14 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u14 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/14.json")
(try! (nft-mint? lampe-de-traverse u15 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u15 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/15.json")
(try! (nft-mint? lampe-de-traverse u16 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u16 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/16.json")
(try! (nft-mint? lampe-de-traverse u17 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u17 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/17.json")
(try! (nft-mint? lampe-de-traverse u18 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u18 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/18.json")
(try! (nft-mint? lampe-de-traverse u19 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u19 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/19.json")
(try! (nft-mint? lampe-de-traverse u20 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u20 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/20.json")
(try! (nft-mint? lampe-de-traverse u21 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u21 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/21.json")
(try! (nft-mint? lampe-de-traverse u22 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u22 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/22.json")
(try! (nft-mint? lampe-de-traverse u23 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u23 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/23.json")
(try! (nft-mint? lampe-de-traverse u24 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u24 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/24.json")
(try! (nft-mint? lampe-de-traverse u25 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u25 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/25.json")
(try! (nft-mint? lampe-de-traverse u26 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u26 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/26.json")
(try! (nft-mint? lampe-de-traverse u27 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u27 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/27.json")
(try! (nft-mint? lampe-de-traverse u28 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u28 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/28.json")
(try! (nft-mint? lampe-de-traverse u29 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u29 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/29.json")
(try! (nft-mint? lampe-de-traverse u30 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u30 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/30.json")
(try! (nft-mint? lampe-de-traverse u31 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u31 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/31.json")
(try! (nft-mint? lampe-de-traverse u32 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u32 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/32.json")
(try! (nft-mint? lampe-de-traverse u33 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u33 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/33.json")
(try! (nft-mint? lampe-de-traverse u34 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u34 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/34.json")
(try! (nft-mint? lampe-de-traverse u35 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u35 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/35.json")
(try! (nft-mint? lampe-de-traverse u36 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u36 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/36.json")
(try! (nft-mint? lampe-de-traverse u37 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u37 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/37.json")
(try! (nft-mint? lampe-de-traverse u38 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u38 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/38.json")
(try! (nft-mint? lampe-de-traverse u39 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u39 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/39.json")
(try! (nft-mint? lampe-de-traverse u40 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u40 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/40.json")
(try! (nft-mint? lampe-de-traverse u41 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u41 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/41.json")
(try! (nft-mint? lampe-de-traverse u42 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u42 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/42.json")
(try! (nft-mint? lampe-de-traverse u43 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u43 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/43.json")
(try! (nft-mint? lampe-de-traverse u44 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u44 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/44.json")
(try! (nft-mint? lampe-de-traverse u45 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u45 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/45.json")
(try! (nft-mint? lampe-de-traverse u46 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u46 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/46.json")
(try! (nft-mint? lampe-de-traverse u47 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u47 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/47.json")
(try! (nft-mint? lampe-de-traverse u48 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u48 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/48.json")
(try! (nft-mint? lampe-de-traverse u49 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u49 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/49.json")
(try! (nft-mint? lampe-de-traverse u50 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV))
(map-set token-count 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV (+ (get-balance 'SPKXP6A04Z6EZTJGKV6RDNGQD1T6J792A6ER6WKV) u1))
(map-set cids u50 "QmVDVGSf3Gw1CSq6sQ9xBE6bx8c6gtkeSHL3k7rMPKXTqu/json/50.json")
(var-set last-id u50)

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