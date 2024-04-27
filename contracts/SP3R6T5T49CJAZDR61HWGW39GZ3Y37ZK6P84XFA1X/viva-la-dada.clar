;; viva-la-dada
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token viva-la-dada uint)

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
(define-data-var artist-address principal 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X)
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
    (nft-burn? viva-la-dada token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? viva-la-dada token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? viva-la-dada token-id)))

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
    (unwrap! (nft-mint? viva-la-dada next-id tx-sender) next-id)
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
  (match (nft-transfer? viva-la-dada id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? viva-la-dada id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? viva-la-dada id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? viva-la-dada u1 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u1 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/1.json")
(try! (nft-mint? viva-la-dada u2 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u2 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/2.json")
(try! (nft-mint? viva-la-dada u3 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u3 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/3.json")
(try! (nft-mint? viva-la-dada u4 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u4 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/4.json")
(try! (nft-mint? viva-la-dada u5 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u5 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/5.json")
(try! (nft-mint? viva-la-dada u6 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u6 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/6.json")
(try! (nft-mint? viva-la-dada u7 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u7 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/7.json")
(try! (nft-mint? viva-la-dada u8 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u8 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/8.json")
(try! (nft-mint? viva-la-dada u9 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u9 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/9.json")
(try! (nft-mint? viva-la-dada u10 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u10 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/10.json")
(try! (nft-mint? viva-la-dada u11 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u11 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/11.json")
(try! (nft-mint? viva-la-dada u12 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u12 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/12.json")
(try! (nft-mint? viva-la-dada u13 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u13 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/13.json")
(try! (nft-mint? viva-la-dada u14 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u14 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/14.json")
(try! (nft-mint? viva-la-dada u15 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u15 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/15.json")
(try! (nft-mint? viva-la-dada u16 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u16 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/16.json")
(try! (nft-mint? viva-la-dada u17 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u17 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/17.json")
(try! (nft-mint? viva-la-dada u18 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u18 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/18.json")
(try! (nft-mint? viva-la-dada u19 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u19 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/19.json")
(try! (nft-mint? viva-la-dada u20 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u20 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/20.json")
(try! (nft-mint? viva-la-dada u21 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u21 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/21.json")
(try! (nft-mint? viva-la-dada u22 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u22 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/22.json")
(try! (nft-mint? viva-la-dada u23 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u23 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/23.json")
(try! (nft-mint? viva-la-dada u24 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u24 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/24.json")
(try! (nft-mint? viva-la-dada u25 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u25 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/25.json")
(try! (nft-mint? viva-la-dada u26 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u26 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/26.json")
(try! (nft-mint? viva-la-dada u27 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u27 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/27.json")
(try! (nft-mint? viva-la-dada u28 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u28 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/28.json")
(try! (nft-mint? viva-la-dada u29 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u29 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/29.json")
(try! (nft-mint? viva-la-dada u30 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u30 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/30.json")
(try! (nft-mint? viva-la-dada u31 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u31 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/31.json")
(try! (nft-mint? viva-la-dada u32 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u32 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/32.json")
(try! (nft-mint? viva-la-dada u33 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u33 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/33.json")
(try! (nft-mint? viva-la-dada u34 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u34 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/34.json")
(try! (nft-mint? viva-la-dada u35 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u35 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/35.json")
(try! (nft-mint? viva-la-dada u36 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u36 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/36.json")
(try! (nft-mint? viva-la-dada u37 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u37 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/37.json")
(try! (nft-mint? viva-la-dada u38 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u38 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/38.json")
(try! (nft-mint? viva-la-dada u39 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u39 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/39.json")
(try! (nft-mint? viva-la-dada u40 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u40 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/40.json")
(try! (nft-mint? viva-la-dada u41 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u41 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/41.json")
(try! (nft-mint? viva-la-dada u42 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u42 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/42.json")
(try! (nft-mint? viva-la-dada u43 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u43 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/43.json")
(try! (nft-mint? viva-la-dada u44 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u44 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/44.json")
(try! (nft-mint? viva-la-dada u45 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u45 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/45.json")
(try! (nft-mint? viva-la-dada u46 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u46 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/46.json")
(try! (nft-mint? viva-la-dada u47 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u47 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/47.json")
(try! (nft-mint? viva-la-dada u48 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u48 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/48.json")
(try! (nft-mint? viva-la-dada u49 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u49 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/49.json")
(try! (nft-mint? viva-la-dada u50 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u50 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/50.json")
(try! (nft-mint? viva-la-dada u51 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u51 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/51.json")
(try! (nft-mint? viva-la-dada u52 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u52 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/52.json")
(try! (nft-mint? viva-la-dada u53 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u53 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/53.json")
(try! (nft-mint? viva-la-dada u54 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u54 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/54.json")
(try! (nft-mint? viva-la-dada u55 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u55 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/55.json")
(try! (nft-mint? viva-la-dada u56 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u56 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/56.json")
(try! (nft-mint? viva-la-dada u57 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u57 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/57.json")
(try! (nft-mint? viva-la-dada u58 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u58 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/58.json")
(try! (nft-mint? viva-la-dada u59 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u59 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/59.json")
(try! (nft-mint? viva-la-dada u60 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u60 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/60.json")
(try! (nft-mint? viva-la-dada u61 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u61 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/61.json")
(try! (nft-mint? viva-la-dada u62 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u62 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/62.json")
(try! (nft-mint? viva-la-dada u63 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u63 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/63.json")
(try! (nft-mint? viva-la-dada u64 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u64 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/64.json")
(try! (nft-mint? viva-la-dada u65 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u65 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/65.json")
(try! (nft-mint? viva-la-dada u66 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u66 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/66.json")
(try! (nft-mint? viva-la-dada u67 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u67 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/67.json")
(try! (nft-mint? viva-la-dada u68 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u68 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/68.json")
(try! (nft-mint? viva-la-dada u69 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u69 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/69.json")
(try! (nft-mint? viva-la-dada u70 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u70 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/70.json")
(try! (nft-mint? viva-la-dada u71 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u71 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/71.json")
(try! (nft-mint? viva-la-dada u72 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u72 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/72.json")
(try! (nft-mint? viva-la-dada u73 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u73 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/73.json")
(try! (nft-mint? viva-la-dada u74 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u74 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/74.json")
(try! (nft-mint? viva-la-dada u75 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u75 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/75.json")
(try! (nft-mint? viva-la-dada u76 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u76 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/76.json")
(try! (nft-mint? viva-la-dada u77 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u77 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/77.json")
(try! (nft-mint? viva-la-dada u78 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u78 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/78.json")
(try! (nft-mint? viva-la-dada u79 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u79 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/79.json")
(try! (nft-mint? viva-la-dada u80 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u80 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/80.json")
(try! (nft-mint? viva-la-dada u81 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u81 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/81.json")
(try! (nft-mint? viva-la-dada u82 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u82 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/82.json")
(try! (nft-mint? viva-la-dada u83 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u83 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/83.json")
(try! (nft-mint? viva-la-dada u84 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u84 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/84.json")
(try! (nft-mint? viva-la-dada u85 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u85 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/85.json")
(try! (nft-mint? viva-la-dada u86 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u86 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/86.json")
(try! (nft-mint? viva-la-dada u87 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u87 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/87.json")
(try! (nft-mint? viva-la-dada u88 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u88 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/88.json")
(try! (nft-mint? viva-la-dada u89 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u89 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/89.json")
(try! (nft-mint? viva-la-dada u90 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u90 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/90.json")
(try! (nft-mint? viva-la-dada u91 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u91 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/91.json")
(try! (nft-mint? viva-la-dada u92 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u92 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/92.json")
(try! (nft-mint? viva-la-dada u93 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u93 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/93.json")
(try! (nft-mint? viva-la-dada u94 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u94 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/94.json")
(try! (nft-mint? viva-la-dada u95 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u95 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/95.json")
(try! (nft-mint? viva-la-dada u96 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u96 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/96.json")
(try! (nft-mint? viva-la-dada u97 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u97 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/97.json")
(try! (nft-mint? viva-la-dada u98 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u98 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/98.json")
(try! (nft-mint? viva-la-dada u99 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X))
(map-set token-count 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X (+ (get-balance 'SP3R6T5T49CJAZDR61HWGW39GZ3Y37ZK6P84XFA1X) u1))
(map-set cids u99 "QmVGgXWn1Aq64Ctz4pYDXu4sR6PMf8nTJFGckcrY8Ckobf/json/99.json")
(var-set last-id u99)

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