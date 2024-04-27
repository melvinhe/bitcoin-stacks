;; poker-anons
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token poker-anons uint)

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
(define-data-var artist-address principal 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9)
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
    (nft-burn? poker-anons token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? poker-anons token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? poker-anons token-id)))

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
    (unwrap! (nft-mint? poker-anons next-id tx-sender) next-id)
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
  (match (nft-transfer? poker-anons id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? poker-anons id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? poker-anons id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? poker-anons u1 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u1 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/1.json")
(try! (nft-mint? poker-anons u2 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u2 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/2.json")
(try! (nft-mint? poker-anons u3 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u3 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/3.json")
(try! (nft-mint? poker-anons u4 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u4 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/4.json")
(try! (nft-mint? poker-anons u5 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u5 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/5.json")
(try! (nft-mint? poker-anons u6 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u6 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/6.json")
(try! (nft-mint? poker-anons u7 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u7 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/7.json")
(try! (nft-mint? poker-anons u8 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u8 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/8.json")
(try! (nft-mint? poker-anons u9 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u9 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/9.json")
(try! (nft-mint? poker-anons u10 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u10 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/10.json")
(try! (nft-mint? poker-anons u11 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u11 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/11.json")
(try! (nft-mint? poker-anons u12 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u12 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/12.json")
(try! (nft-mint? poker-anons u13 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u13 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/13.json")
(try! (nft-mint? poker-anons u14 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u14 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/14.json")
(try! (nft-mint? poker-anons u15 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u15 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/15.json")
(try! (nft-mint? poker-anons u16 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u16 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/16.json")
(try! (nft-mint? poker-anons u17 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u17 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/17.json")
(try! (nft-mint? poker-anons u18 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u18 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/18.json")
(try! (nft-mint? poker-anons u19 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u19 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/19.json")
(try! (nft-mint? poker-anons u20 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u20 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/20.json")
(try! (nft-mint? poker-anons u21 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u21 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/21.json")
(try! (nft-mint? poker-anons u22 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u22 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/22.json")
(try! (nft-mint? poker-anons u23 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u23 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/23.json")
(try! (nft-mint? poker-anons u24 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u24 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/24.json")
(try! (nft-mint? poker-anons u25 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u25 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/25.json")
(try! (nft-mint? poker-anons u26 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u26 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/26.json")
(try! (nft-mint? poker-anons u27 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u27 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/27.json")
(try! (nft-mint? poker-anons u28 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u28 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/28.json")
(try! (nft-mint? poker-anons u29 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u29 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/29.json")
(try! (nft-mint? poker-anons u30 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u30 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/30.json")
(try! (nft-mint? poker-anons u31 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u31 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/31.json")
(try! (nft-mint? poker-anons u32 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u32 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/32.json")
(try! (nft-mint? poker-anons u33 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u33 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/33.json")
(try! (nft-mint? poker-anons u34 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u34 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/34.json")
(try! (nft-mint? poker-anons u35 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u35 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/35.json")
(try! (nft-mint? poker-anons u36 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u36 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/36.json")
(try! (nft-mint? poker-anons u37 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u37 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/37.json")
(try! (nft-mint? poker-anons u38 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u38 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/38.json")
(try! (nft-mint? poker-anons u39 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u39 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/39.json")
(try! (nft-mint? poker-anons u40 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u40 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/40.json")
(try! (nft-mint? poker-anons u41 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u41 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/41.json")
(try! (nft-mint? poker-anons u42 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u42 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/42.json")
(try! (nft-mint? poker-anons u43 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u43 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/43.json")
(try! (nft-mint? poker-anons u44 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u44 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/44.json")
(try! (nft-mint? poker-anons u45 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u45 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/45.json")
(try! (nft-mint? poker-anons u46 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u46 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/46.json")
(try! (nft-mint? poker-anons u47 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u47 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/47.json")
(try! (nft-mint? poker-anons u48 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u48 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/48.json")
(try! (nft-mint? poker-anons u49 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u49 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/49.json")
(try! (nft-mint? poker-anons u50 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u50 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/50.json")
(try! (nft-mint? poker-anons u51 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u51 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/51.json")
(try! (nft-mint? poker-anons u52 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u52 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/52.json")
(try! (nft-mint? poker-anons u53 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u53 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/53.json")
(try! (nft-mint? poker-anons u54 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u54 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/54.json")
(try! (nft-mint? poker-anons u55 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u55 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/55.json")
(try! (nft-mint? poker-anons u56 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u56 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/56.json")
(try! (nft-mint? poker-anons u57 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u57 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/57.json")
(try! (nft-mint? poker-anons u58 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u58 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/58.json")
(try! (nft-mint? poker-anons u59 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u59 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/59.json")
(try! (nft-mint? poker-anons u60 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u60 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/60.json")
(try! (nft-mint? poker-anons u61 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u61 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/61.json")
(try! (nft-mint? poker-anons u62 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u62 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/62.json")
(try! (nft-mint? poker-anons u63 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u63 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/63.json")
(try! (nft-mint? poker-anons u64 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u64 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/64.json")
(try! (nft-mint? poker-anons u65 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u65 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/65.json")
(try! (nft-mint? poker-anons u66 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u66 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/66.json")
(try! (nft-mint? poker-anons u67 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u67 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/67.json")
(try! (nft-mint? poker-anons u68 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u68 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/68.json")
(try! (nft-mint? poker-anons u69 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u69 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/69.json")
(try! (nft-mint? poker-anons u70 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u70 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/70.json")
(try! (nft-mint? poker-anons u71 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u71 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/71.json")
(try! (nft-mint? poker-anons u72 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u72 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/72.json")
(try! (nft-mint? poker-anons u73 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u73 "QmQiX8BWFAahPReQ2HxDYruFHUXDZXFLm7X9s8DwKjRMJL/json/73.json")
(var-set last-id u73)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/1")
(define-data-var license-name (string-ascii 40) "EXCLUSIVE")

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