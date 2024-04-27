;; ordinal-mystic-clan
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token ordinal-mystic-clan uint)

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
(define-data-var artist-address principal 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A)
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
    (nft-burn? ordinal-mystic-clan token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? ordinal-mystic-clan token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? ordinal-mystic-clan token-id)))

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
    (unwrap! (nft-mint? ordinal-mystic-clan next-id tx-sender) next-id)
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
  (match (nft-transfer? ordinal-mystic-clan id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? ordinal-mystic-clan id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? ordinal-mystic-clan id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? ordinal-mystic-clan u1 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u1 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/1.json")
(try! (nft-mint? ordinal-mystic-clan u2 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u2 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/2.json")
(try! (nft-mint? ordinal-mystic-clan u3 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u3 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/3.json")
(try! (nft-mint? ordinal-mystic-clan u4 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u4 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/4.json")
(try! (nft-mint? ordinal-mystic-clan u5 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u5 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/5.json")
(try! (nft-mint? ordinal-mystic-clan u6 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u6 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/6.json")
(try! (nft-mint? ordinal-mystic-clan u7 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u7 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/7.json")
(try! (nft-mint? ordinal-mystic-clan u8 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u8 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/8.json")
(try! (nft-mint? ordinal-mystic-clan u9 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u9 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/9.json")
(try! (nft-mint? ordinal-mystic-clan u10 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u10 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/10.json")
(try! (nft-mint? ordinal-mystic-clan u11 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u11 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/11.json")
(try! (nft-mint? ordinal-mystic-clan u12 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u12 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/12.json")
(try! (nft-mint? ordinal-mystic-clan u13 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u13 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/13.json")
(try! (nft-mint? ordinal-mystic-clan u14 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u14 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/14.json")
(try! (nft-mint? ordinal-mystic-clan u15 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u15 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/15.json")
(try! (nft-mint? ordinal-mystic-clan u16 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u16 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/16.json")
(try! (nft-mint? ordinal-mystic-clan u17 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u17 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/17.json")
(try! (nft-mint? ordinal-mystic-clan u18 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u18 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/18.json")
(try! (nft-mint? ordinal-mystic-clan u19 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u19 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/19.json")
(try! (nft-mint? ordinal-mystic-clan u20 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u20 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/20.json")
(try! (nft-mint? ordinal-mystic-clan u21 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u21 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/21.json")
(try! (nft-mint? ordinal-mystic-clan u22 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u22 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/22.json")
(try! (nft-mint? ordinal-mystic-clan u23 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u23 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/23.json")
(try! (nft-mint? ordinal-mystic-clan u24 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u24 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/24.json")
(try! (nft-mint? ordinal-mystic-clan u25 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u25 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/25.json")
(try! (nft-mint? ordinal-mystic-clan u26 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u26 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/26.json")
(try! (nft-mint? ordinal-mystic-clan u27 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u27 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/27.json")
(try! (nft-mint? ordinal-mystic-clan u28 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u28 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/28.json")
(try! (nft-mint? ordinal-mystic-clan u29 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u29 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/29.json")
(try! (nft-mint? ordinal-mystic-clan u30 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u30 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/30.json")
(try! (nft-mint? ordinal-mystic-clan u31 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u31 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/31.json")
(try! (nft-mint? ordinal-mystic-clan u32 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u32 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/32.json")
(try! (nft-mint? ordinal-mystic-clan u33 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u33 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/33.json")
(try! (nft-mint? ordinal-mystic-clan u34 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u34 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/34.json")
(try! (nft-mint? ordinal-mystic-clan u35 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u35 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/35.json")
(try! (nft-mint? ordinal-mystic-clan u36 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u36 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/36.json")
(try! (nft-mint? ordinal-mystic-clan u37 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u37 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/37.json")
(try! (nft-mint? ordinal-mystic-clan u38 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u38 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/38.json")
(try! (nft-mint? ordinal-mystic-clan u39 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u39 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/39.json")
(try! (nft-mint? ordinal-mystic-clan u40 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u40 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/40.json")
(try! (nft-mint? ordinal-mystic-clan u41 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u41 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/41.json")
(try! (nft-mint? ordinal-mystic-clan u42 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u42 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/42.json")
(try! (nft-mint? ordinal-mystic-clan u43 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u43 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/43.json")
(try! (nft-mint? ordinal-mystic-clan u44 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u44 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/44.json")
(try! (nft-mint? ordinal-mystic-clan u45 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u45 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/45.json")
(try! (nft-mint? ordinal-mystic-clan u46 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u46 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/46.json")
(try! (nft-mint? ordinal-mystic-clan u47 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u47 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/47.json")
(try! (nft-mint? ordinal-mystic-clan u48 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u48 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/48.json")
(try! (nft-mint? ordinal-mystic-clan u49 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u49 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/49.json")
(try! (nft-mint? ordinal-mystic-clan u50 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u50 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/50.json")
(try! (nft-mint? ordinal-mystic-clan u51 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u51 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/51.json")
(try! (nft-mint? ordinal-mystic-clan u52 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u52 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/52.json")
(try! (nft-mint? ordinal-mystic-clan u53 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u53 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/53.json")
(try! (nft-mint? ordinal-mystic-clan u54 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u54 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/54.json")
(try! (nft-mint? ordinal-mystic-clan u55 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u55 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/55.json")
(try! (nft-mint? ordinal-mystic-clan u56 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u56 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/56.json")
(try! (nft-mint? ordinal-mystic-clan u57 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u57 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/57.json")
(try! (nft-mint? ordinal-mystic-clan u58 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u58 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/58.json")
(try! (nft-mint? ordinal-mystic-clan u59 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u59 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/59.json")
(try! (nft-mint? ordinal-mystic-clan u60 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u60 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/60.json")
(try! (nft-mint? ordinal-mystic-clan u61 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u61 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/61.json")
(try! (nft-mint? ordinal-mystic-clan u62 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u62 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/62.json")
(try! (nft-mint? ordinal-mystic-clan u63 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u63 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/63.json")
(try! (nft-mint? ordinal-mystic-clan u64 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u64 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/64.json")
(try! (nft-mint? ordinal-mystic-clan u65 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u65 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/65.json")
(try! (nft-mint? ordinal-mystic-clan u66 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u66 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/66.json")
(try! (nft-mint? ordinal-mystic-clan u67 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u67 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/67.json")
(try! (nft-mint? ordinal-mystic-clan u68 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u68 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/68.json")
(try! (nft-mint? ordinal-mystic-clan u69 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u69 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/69.json")
(try! (nft-mint? ordinal-mystic-clan u70 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u70 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/70.json")
(try! (nft-mint? ordinal-mystic-clan u71 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u71 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/71.json")
(try! (nft-mint? ordinal-mystic-clan u72 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u72 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/72.json")
(try! (nft-mint? ordinal-mystic-clan u73 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u73 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/73.json")
(try! (nft-mint? ordinal-mystic-clan u74 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u74 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/74.json")
(try! (nft-mint? ordinal-mystic-clan u75 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u75 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/75.json")
(try! (nft-mint? ordinal-mystic-clan u76 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u76 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/76.json")
(try! (nft-mint? ordinal-mystic-clan u77 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u77 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/77.json")
(try! (nft-mint? ordinal-mystic-clan u78 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u78 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/78.json")
(try! (nft-mint? ordinal-mystic-clan u79 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u79 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/79.json")
(try! (nft-mint? ordinal-mystic-clan u80 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u80 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/80.json")
(try! (nft-mint? ordinal-mystic-clan u81 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u81 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/81.json")
(try! (nft-mint? ordinal-mystic-clan u82 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u82 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/82.json")
(try! (nft-mint? ordinal-mystic-clan u83 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u83 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/83.json")
(try! (nft-mint? ordinal-mystic-clan u84 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u84 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/84.json")
(try! (nft-mint? ordinal-mystic-clan u85 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u85 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/85.json")
(try! (nft-mint? ordinal-mystic-clan u86 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u86 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/86.json")
(try! (nft-mint? ordinal-mystic-clan u87 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u87 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/87.json")
(try! (nft-mint? ordinal-mystic-clan u88 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u88 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/88.json")
(try! (nft-mint? ordinal-mystic-clan u89 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u89 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/89.json")
(try! (nft-mint? ordinal-mystic-clan u90 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u90 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/90.json")
(try! (nft-mint? ordinal-mystic-clan u91 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u91 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/91.json")
(try! (nft-mint? ordinal-mystic-clan u92 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u92 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/92.json")
(try! (nft-mint? ordinal-mystic-clan u93 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u93 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/93.json")
(try! (nft-mint? ordinal-mystic-clan u94 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u94 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/94.json")
(try! (nft-mint? ordinal-mystic-clan u95 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u95 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/95.json")
(try! (nft-mint? ordinal-mystic-clan u96 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u96 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/96.json")
(try! (nft-mint? ordinal-mystic-clan u97 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u97 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/97.json")
(try! (nft-mint? ordinal-mystic-clan u98 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u98 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/98.json")
(try! (nft-mint? ordinal-mystic-clan u99 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u99 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/99.json")
(try! (nft-mint? ordinal-mystic-clan u100 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A))
(map-set token-count 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A (+ (get-balance 'SP2MT4YF9N2S0S22KW4GNK8497FC0GT2FQNW4TW6A) u1))
(map-set cids u100 "QmdKggRFes6NX8adw2Kqoi6TJTpnCz3zwEV3sYB9r1vu3Z/json/100.json")
(var-set last-id u100)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/0")
(define-data-var license-name (string-ascii 40) "PUBLIC")

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