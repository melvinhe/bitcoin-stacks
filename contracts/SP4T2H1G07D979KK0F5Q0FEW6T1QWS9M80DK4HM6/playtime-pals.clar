;; playtime-pals
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token playtime-pals uint)

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
(define-data-var artist-address principal 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6)
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
    (nft-burn? playtime-pals token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? playtime-pals token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? playtime-pals token-id)))

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
    (unwrap! (nft-mint? playtime-pals next-id tx-sender) next-id)
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
  (match (nft-transfer? playtime-pals id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? playtime-pals id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? playtime-pals id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? playtime-pals u1 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u1 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/1.json")
(try! (nft-mint? playtime-pals u2 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u2 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/2.json")
(try! (nft-mint? playtime-pals u3 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u3 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/3.json")
(try! (nft-mint? playtime-pals u4 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u4 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/4.json")
(try! (nft-mint? playtime-pals u5 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u5 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/5.json")
(try! (nft-mint? playtime-pals u6 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u6 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/6.json")
(try! (nft-mint? playtime-pals u7 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u7 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/7.json")
(try! (nft-mint? playtime-pals u8 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u8 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/8.json")
(try! (nft-mint? playtime-pals u9 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u9 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/9.json")
(try! (nft-mint? playtime-pals u10 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u10 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/10.json")
(try! (nft-mint? playtime-pals u11 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u11 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/11.json")
(try! (nft-mint? playtime-pals u12 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u12 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/12.json")
(try! (nft-mint? playtime-pals u13 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u13 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/13.json")
(try! (nft-mint? playtime-pals u14 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u14 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/14.json")
(try! (nft-mint? playtime-pals u15 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u15 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/15.json")
(try! (nft-mint? playtime-pals u16 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u16 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/16.json")
(try! (nft-mint? playtime-pals u17 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u17 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/17.json")
(try! (nft-mint? playtime-pals u18 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u18 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/18.json")
(try! (nft-mint? playtime-pals u19 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u19 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/19.json")
(try! (nft-mint? playtime-pals u20 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u20 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/20.json")
(try! (nft-mint? playtime-pals u21 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u21 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/21.json")
(try! (nft-mint? playtime-pals u22 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u22 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/22.json")
(try! (nft-mint? playtime-pals u23 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u23 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/23.json")
(try! (nft-mint? playtime-pals u24 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u24 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/24.json")
(try! (nft-mint? playtime-pals u25 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u25 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/25.json")
(try! (nft-mint? playtime-pals u26 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u26 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/26.json")
(try! (nft-mint? playtime-pals u27 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u27 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/27.json")
(try! (nft-mint? playtime-pals u28 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u28 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/28.json")
(try! (nft-mint? playtime-pals u29 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u29 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/29.json")
(try! (nft-mint? playtime-pals u30 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u30 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/30.json")
(try! (nft-mint? playtime-pals u31 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u31 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/31.json")
(try! (nft-mint? playtime-pals u32 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u32 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/32.json")
(try! (nft-mint? playtime-pals u33 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u33 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/33.json")
(try! (nft-mint? playtime-pals u34 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u34 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/34.json")
(try! (nft-mint? playtime-pals u35 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u35 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/35.json")
(try! (nft-mint? playtime-pals u36 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u36 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/36.json")
(try! (nft-mint? playtime-pals u37 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u37 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/37.json")
(try! (nft-mint? playtime-pals u38 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u38 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/38.json")
(try! (nft-mint? playtime-pals u39 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u39 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/39.json")
(try! (nft-mint? playtime-pals u40 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u40 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/40.json")
(try! (nft-mint? playtime-pals u41 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u41 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/41.json")
(try! (nft-mint? playtime-pals u42 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u42 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/42.json")
(try! (nft-mint? playtime-pals u43 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u43 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/43.json")
(try! (nft-mint? playtime-pals u44 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u44 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/44.json")
(try! (nft-mint? playtime-pals u45 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u45 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/45.json")
(try! (nft-mint? playtime-pals u46 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u46 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/46.json")
(try! (nft-mint? playtime-pals u47 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u47 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/47.json")
(try! (nft-mint? playtime-pals u48 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u48 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/48.json")
(try! (nft-mint? playtime-pals u49 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u49 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/49.json")
(try! (nft-mint? playtime-pals u50 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6))
(map-set token-count 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6 (+ (get-balance 'SP4T2H1G07D979KK0F5Q0FEW6T1QWS9M80DK4HM6) u1))
(map-set cids u50 "QmRNMbDUNaBohF47MTtHtSGSKne9RzeyvY7yVxt7Wu9wwn/json/50.json")
(var-set last-id u50)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/3")
(define-data-var license-name (string-ascii 40) "COMMERCIAL-NO-HATE")

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