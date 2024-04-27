;; gm-loyalty-pass
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token gm-loyalty-pass uint)

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
(define-constant ERR-INVALID-PERCENTAGE u114)

;; Internal variables
(define-data-var mint-limit uint u86)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP19FTGFZKW4W1GV2Y3QAD2MVNDM3J0DY3NJWVC4Z)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmUF5a1oR6jYEkgtA5pjcqCXQ8rVo5mN36QMXRxCQrCVvj/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

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
      (unwrap! (nft-mint? gm-loyalty-pass next-id tx-sender) next-id)
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
    (asserts! (is-none (map-get? market token-id)) (err ERR-LISTING))
    (nft-burn? gm-loyalty-pass token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? gm-loyalty-pass token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (print { notification: "token-metadata-update", payload: { token-class: "nft", contract-id: (as-contract tx-sender) }})
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
  (ok (nft-get-owner? gm-loyalty-pass token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/5")
(define-data-var license-name (string-ascii 40) "PERSONAL-NO-HATE")

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

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? gm-loyalty-pass id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? gm-loyalty-pass id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? gm-loyalty-pass id) (err ERR-NOT-FOUND)))
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
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u0) 'SP14TMQH37FXX0XG577R6D3426SPX1QT0KMEG0ZXJ))
      (map-set token-count 'SP14TMQH37FXX0XG577R6D3426SPX1QT0KMEG0ZXJ (+ (get-balance 'SP14TMQH37FXX0XG577R6D3426SPX1QT0KMEG0ZXJ) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u1) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u2) 'SP1ATAR793F62BQDB427EDATEYBGGFQA8ABZ2FA4Y))
      (map-set token-count 'SP1ATAR793F62BQDB427EDATEYBGGFQA8ABZ2FA4Y (+ (get-balance 'SP1ATAR793F62BQDB427EDATEYBGGFQA8ABZ2FA4Y) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u3) 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV))
      (map-set token-count 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV (+ (get-balance 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u4) 'SP1FPD5TJ6CPWMS0D1Q93S5ACBB6SQNF7DS4SGBHM))
      (map-set token-count 'SP1FPD5TJ6CPWMS0D1Q93S5ACBB6SQNF7DS4SGBHM (+ (get-balance 'SP1FPD5TJ6CPWMS0D1Q93S5ACBB6SQNF7DS4SGBHM) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u5) 'SP1K3MM3SQ2XM9GZRBBRFWKE09Z117EJ8Z6PT4D73))
      (map-set token-count 'SP1K3MM3SQ2XM9GZRBBRFWKE09Z117EJ8Z6PT4D73 (+ (get-balance 'SP1K3MM3SQ2XM9GZRBBRFWKE09Z117EJ8Z6PT4D73) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u6) 'SP1KC3BEGRFE9CNV1Q6G3H3TBAA36Q4TZGRS6J322))
      (map-set token-count 'SP1KC3BEGRFE9CNV1Q6G3H3TBAA36Q4TZGRS6J322 (+ (get-balance 'SP1KC3BEGRFE9CNV1Q6G3H3TBAA36Q4TZGRS6J322) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u7) 'SP1MKK6B8HMVYZCAD6KEV4BBNM3ER628ATA9ZPKZ4))
      (map-set token-count 'SP1MKK6B8HMVYZCAD6KEV4BBNM3ER628ATA9ZPKZ4 (+ (get-balance 'SP1MKK6B8HMVYZCAD6KEV4BBNM3ER628ATA9ZPKZ4) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u8) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u9) 'SP1REM0ZMCFWY70CXAQMGYDMYCEC1SZKHVQ6ZR8JR))
      (map-set token-count 'SP1REM0ZMCFWY70CXAQMGYDMYCEC1SZKHVQ6ZR8JR (+ (get-balance 'SP1REM0ZMCFWY70CXAQMGYDMYCEC1SZKHVQ6ZR8JR) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u10) 'SP1TS6MC7DTJ538F6F4F6ZB2K376DT1GTTY552FCW))
      (map-set token-count 'SP1TS6MC7DTJ538F6F4F6ZB2K376DT1GTTY552FCW (+ (get-balance 'SP1TS6MC7DTJ538F6F4F6ZB2K376DT1GTTY552FCW) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u11) 'SP1XNJH1NZX90QV2VJE5QAPB7YAE3WHFY2NAH3JCC))
      (map-set token-count 'SP1XNJH1NZX90QV2VJE5QAPB7YAE3WHFY2NAH3JCC (+ (get-balance 'SP1XNJH1NZX90QV2VJE5QAPB7YAE3WHFY2NAH3JCC) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u12) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u13) 'SP27D2H2WEQS7AQS3C7CY9T4TK8JQEH9WD11PN6VZ))
      (map-set token-count 'SP27D2H2WEQS7AQS3C7CY9T4TK8JQEH9WD11PN6VZ (+ (get-balance 'SP27D2H2WEQS7AQS3C7CY9T4TK8JQEH9WD11PN6VZ) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u14) 'SP27K1498HEGJSSVMFH64NTRJXSWEQN5H22S9TZ8M))
      (map-set token-count 'SP27K1498HEGJSSVMFH64NTRJXSWEQN5H22S9TZ8M (+ (get-balance 'SP27K1498HEGJSSVMFH64NTRJXSWEQN5H22S9TZ8M) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u15) 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168))
      (map-set token-count 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168 (+ (get-balance 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u16) 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK))
      (map-set token-count 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK (+ (get-balance 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u17) 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH))
      (map-set token-count 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH (+ (get-balance 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u18) 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN))
      (map-set token-count 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN (+ (get-balance 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u19) 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX))
      (map-set token-count 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX (+ (get-balance 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u20) 'SP2NYMCHYXB8AMG1Z3SB12KHTSMDSQV3MBDPDNKNC))
      (map-set token-count 'SP2NYMCHYXB8AMG1Z3SB12KHTSMDSQV3MBDPDNKNC (+ (get-balance 'SP2NYMCHYXB8AMG1Z3SB12KHTSMDSQV3MBDPDNKNC) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u21) 'SP2P7X0H5FAFBN5WDRQNKX4AS2ZCNQTFJ47BEDMNS))
      (map-set token-count 'SP2P7X0H5FAFBN5WDRQNKX4AS2ZCNQTFJ47BEDMNS (+ (get-balance 'SP2P7X0H5FAFBN5WDRQNKX4AS2ZCNQTFJ47BEDMNS) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u22) 'SP2V16FKN22BJK1SG49S7AM51SNAQH9DXR2Z4BSQH))
      (map-set token-count 'SP2V16FKN22BJK1SG49S7AM51SNAQH9DXR2Z4BSQH (+ (get-balance 'SP2V16FKN22BJK1SG49S7AM51SNAQH9DXR2Z4BSQH) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u23) 'SP2WJXBW24EFSHAJJGXNX4T7QQW9RK88W15GR7DKN))
      (map-set token-count 'SP2WJXBW24EFSHAJJGXNX4T7QQW9RK88W15GR7DKN (+ (get-balance 'SP2WJXBW24EFSHAJJGXNX4T7QQW9RK88W15GR7DKN) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u24) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u25) 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0))
      (map-set token-count 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 (+ (get-balance 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u26) 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0))
      (map-set token-count 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 (+ (get-balance 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u27) 'SP36WJG2PAMD5MR280C9K6ZE1WJ47N8GEQV2ZK0NY))
      (map-set token-count 'SP36WJG2PAMD5MR280C9K6ZE1WJ47N8GEQV2ZK0NY (+ (get-balance 'SP36WJG2PAMD5MR280C9K6ZE1WJ47N8GEQV2ZK0NY) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u28) 'SP377K719ABJWDFJZNTN2ZB2ZZ2G9MG8NZDQ83NG2))
      (map-set token-count 'SP377K719ABJWDFJZNTN2ZB2ZZ2G9MG8NZDQ83NG2 (+ (get-balance 'SP377K719ABJWDFJZNTN2ZB2ZZ2G9MG8NZDQ83NG2) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u29) 'SP37DWSRH9Y1C6R90VK6VF29S7SRQGDM8ANWA3NX5))
      (map-set token-count 'SP37DWSRH9Y1C6R90VK6VF29S7SRQGDM8ANWA3NX5 (+ (get-balance 'SP37DWSRH9Y1C6R90VK6VF29S7SRQGDM8ANWA3NX5) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u30) 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX))
      (map-set token-count 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX (+ (get-balance 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u31) 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P))
      (map-set token-count 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P (+ (get-balance 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u32) 'SP3BSDRJMXBY7C73NF83T2RPBK3NBRGQMG7PBTJRA))
      (map-set token-count 'SP3BSDRJMXBY7C73NF83T2RPBK3NBRGQMG7PBTJRA (+ (get-balance 'SP3BSDRJMXBY7C73NF83T2RPBK3NBRGQMG7PBTJRA) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u33) 'SP3E6RFGYFMKJDKXT0RFW27C0WN2CEK0T0DWZYVA9))
      (map-set token-count 'SP3E6RFGYFMKJDKXT0RFW27C0WN2CEK0T0DWZYVA9 (+ (get-balance 'SP3E6RFGYFMKJDKXT0RFW27C0WN2CEK0T0DWZYVA9) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u34) 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX))
      (map-set token-count 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX (+ (get-balance 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u35) 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1))
      (map-set token-count 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1 (+ (get-balance 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u36) 'SP3HYFVG35TW1RF47N6RKYYDNPX6T47J6ZJB3B4PE))
      (map-set token-count 'SP3HYFVG35TW1RF47N6RKYYDNPX6T47J6ZJB3B4PE (+ (get-balance 'SP3HYFVG35TW1RF47N6RKYYDNPX6T47J6ZJB3B4PE) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u37) 'SP3JTDMCVTT7SNXM8F0M20SXMD83MC7TAH0E44C14))
      (map-set token-count 'SP3JTDMCVTT7SNXM8F0M20SXMD83MC7TAH0E44C14 (+ (get-balance 'SP3JTDMCVTT7SNXM8F0M20SXMD83MC7TAH0E44C14) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u38) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u39) 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85))
      (map-set token-count 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 (+ (get-balance 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u40) 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR))
      (map-set token-count 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR (+ (get-balance 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u41) 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106))
      (map-set token-count 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 (+ (get-balance 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u42) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u43) 'SP3TZF64TY080GVMZRT4Z87E383Q8EAKZ5W67FCNY))
      (map-set token-count 'SP3TZF64TY080GVMZRT4Z87E383Q8EAKZ5W67FCNY (+ (get-balance 'SP3TZF64TY080GVMZRT4Z87E383Q8EAKZ5W67FCNY) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u44) 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF))
      (map-set token-count 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF (+ (get-balance 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u45) 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W))
      (map-set token-count 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W (+ (get-balance 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u46) 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5))
      (map-set token-count 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5 (+ (get-balance 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u47) 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99))
      (map-set token-count 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 (+ (get-balance 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u48) 'SP3Z5H5KFMGBTYB37DYTGEA14VZG8AT32EPDEAKQH))
      (map-set token-count 'SP3Z5H5KFMGBTYB37DYTGEA14VZG8AT32EPDEAKQH (+ (get-balance 'SP3Z5H5KFMGBTYB37DYTGEA14VZG8AT32EPDEAKQH) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u49) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u50) 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X))
      (map-set token-count 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X (+ (get-balance 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u51) 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG))
      (map-set token-count 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG (+ (get-balance 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u52) 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y))
      (map-set token-count 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y (+ (get-balance 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u53) 'SP7MAP8XJCMRZ9901ETFA3EKVVPJ4X51AWQ2VG4F))
      (map-set token-count 'SP7MAP8XJCMRZ9901ETFA3EKVVPJ4X51AWQ2VG4F (+ (get-balance 'SP7MAP8XJCMRZ9901ETFA3EKVVPJ4X51AWQ2VG4F) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u54) 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV))
      (map-set token-count 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV (+ (get-balance 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u55) 'SPBB2EX5DA1NYAP4M2A2XS2BAQ5Y4VCZ89XDCPY7))
      (map-set token-count 'SPBB2EX5DA1NYAP4M2A2XS2BAQ5Y4VCZ89XDCPY7 (+ (get-balance 'SPBB2EX5DA1NYAP4M2A2XS2BAQ5Y4VCZ89XDCPY7) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u56) 'SPBNAM3RV2ZTXAYRV70PETHWSJ65NA319JXCQX08))
      (map-set token-count 'SPBNAM3RV2ZTXAYRV70PETHWSJ65NA319JXCQX08 (+ (get-balance 'SPBNAM3RV2ZTXAYRV70PETHWSJ65NA319JXCQX08) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u57) 'SPC2XQHNDWAKVSEGTR56HZJFSGTSSFD54EJBB9S6))
      (map-set token-count 'SPC2XQHNDWAKVSEGTR56HZJFSGTSSFD54EJBB9S6 (+ (get-balance 'SPC2XQHNDWAKVSEGTR56HZJFSGTSSFD54EJBB9S6) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u58) 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44))
      (map-set token-count 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44 (+ (get-balance 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u59) 'SPE9CQ6VBE2DER8MG4DJVZ9123CZM0QSVGWXSKWD))
      (map-set token-count 'SPE9CQ6VBE2DER8MG4DJVZ9123CZM0QSVGWXSKWD (+ (get-balance 'SPE9CQ6VBE2DER8MG4DJVZ9123CZM0QSVGWXSKWD) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u60) 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ))
      (map-set token-count 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ (+ (get-balance 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u61) 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S))
      (map-set token-count 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S (+ (get-balance 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u62) 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY))
      (map-set token-count 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY (+ (get-balance 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u63) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u64) 'SPHYYF20CF09CNMY1JN4Q6GPDRT5CECEFVX3JG7G))
      (map-set token-count 'SPHYYF20CF09CNMY1JN4Q6GPDRT5CECEFVX3JG7G (+ (get-balance 'SPHYYF20CF09CNMY1JN4Q6GPDRT5CECEFVX3JG7G) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u65) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u66) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u67) 'SPPDZ2G6ZCY2VHVTTRVPVZS5KCG4JG8T6WEHTC7Z))
      (map-set token-count 'SPPDZ2G6ZCY2VHVTTRVPVZS5KCG4JG8T6WEHTC7Z (+ (get-balance 'SPPDZ2G6ZCY2VHVTTRVPVZS5KCG4JG8T6WEHTC7Z) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u68) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u69) 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3))
      (map-set token-count 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 (+ (get-balance 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u70) 'SPS46Q8P75FGWDX11JNVER71R90VD5MV45XA5X1B))
      (map-set token-count 'SPS46Q8P75FGWDX11JNVER71R90VD5MV45XA5X1B (+ (get-balance 'SPS46Q8P75FGWDX11JNVER71R90VD5MV45XA5X1B) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u71) 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3))
      (map-set token-count 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3 (+ (get-balance 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u72) 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0))
      (map-set token-count 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 (+ (get-balance 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u73) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u74) 'SP27K1498HEGJSSVMFH64NTRJXSWEQN5H22S9TZ8M))
      (map-set token-count 'SP27K1498HEGJSSVMFH64NTRJXSWEQN5H22S9TZ8M (+ (get-balance 'SP27K1498HEGJSSVMFH64NTRJXSWEQN5H22S9TZ8M) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u75) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u76) 'SP3E6RFGYFMKJDKXT0RFW27C0WN2CEK0T0DWZYVA9))
      (map-set token-count 'SP3E6RFGYFMKJDKXT0RFW27C0WN2CEK0T0DWZYVA9 (+ (get-balance 'SP3E6RFGYFMKJDKXT0RFW27C0WN2CEK0T0DWZYVA9) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u77) 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85))
      (map-set token-count 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 (+ (get-balance 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u78) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u79) 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y))
      (map-set token-count 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y (+ (get-balance 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u80) 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV))
      (map-set token-count 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV (+ (get-balance 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u81) 'SPC2XQHNDWAKVSEGTR56HZJFSGTSSFD54EJBB9S6))
      (map-set token-count 'SPC2XQHNDWAKVSEGTR56HZJFSGTSSFD54EJBB9S6 (+ (get-balance 'SPC2XQHNDWAKVSEGTR56HZJFSGTSSFD54EJBB9S6) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u82) 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44))
      (map-set token-count 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44 (+ (get-balance 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u83) 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY))
      (map-set token-count 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY (+ (get-balance 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u84) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? gm-loyalty-pass (+ last-nft-id u85) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))

      (var-set last-id (+ last-nft-id u86))
      (var-set airdrop-called true)
      (ok true))))