;; dogeception-x-arnofromearth
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token dogeception-x-arnofromearth uint)

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
(define-constant ERR-CONTRACT-LOCKED u115)

;; Internal variables
(define-data-var mint-limit uint u24)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmdGgxuVTnrbYQy9VgVAWLdQNB5UxFktma73aHKMoWkFrw/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u1)
(define-data-var locked bool false)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (or (is-eq (var-get mint-limit) u0) (<= last-nft-id (var-get mint-limit))) (err ERR-NO-MORE-NFTS)))
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
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
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
  (if (or (is-eq (var-get mint-limit) u0) (<= next-id (var-get mint-limit)))
    (begin
      (unwrap! (nft-mint? dogeception-x-arnofromearth next-id tx-sender) next-id)
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
    (nft-burn? dogeception-x-arnofromearth token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? dogeception-x-arnofromearth token-id) false)))

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
  (ok (nft-get-owner? dogeception-x-arnofromearth token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-root))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? dogeception-x-arnofromearth id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? dogeception-x-arnofromearth id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? dogeception-x-arnofromearth id) (err ERR-NOT-FOUND)))
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
  (if (> royalty-amount u0)
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
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u0) 'SP1WYKQFCF6BEYZ53TVYNJ9HZFY8C39XN0P6R4CKB))
      (map-set token-count 'SP1WYKQFCF6BEYZ53TVYNJ9HZFY8C39XN0P6R4CKB (+ (get-balance 'SP1WYKQFCF6BEYZ53TVYNJ9HZFY8C39XN0P6R4CKB) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u1) 'SP1SHCVJ32WYGC04TG4GC5HMXFKMG3FP46P66MA4W))
      (map-set token-count 'SP1SHCVJ32WYGC04TG4GC5HMXFKMG3FP46P66MA4W (+ (get-balance 'SP1SHCVJ32WYGC04TG4GC5HMXFKMG3FP46P66MA4W) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u2) 'SPTQ1EPT9GCVSG219475J91VKJF7MPNQYG0EHBZ7))
      (map-set token-count 'SPTQ1EPT9GCVSG219475J91VKJF7MPNQYG0EHBZ7 (+ (get-balance 'SPTQ1EPT9GCVSG219475J91VKJF7MPNQYG0EHBZ7) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u3) 'SP3E545ADCKY56EVCXZPA87525VM0ZA8DQQAEP77Z))
      (map-set token-count 'SP3E545ADCKY56EVCXZPA87525VM0ZA8DQQAEP77Z (+ (get-balance 'SP3E545ADCKY56EVCXZPA87525VM0ZA8DQQAEP77Z) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u4) 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE))
      (map-set token-count 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE (+ (get-balance 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u5) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u6) 'SP87NT88HVA7SR9JKFSM9XKDS59JP2P72HYT3CME))
      (map-set token-count 'SP87NT88HVA7SR9JKFSM9XKDS59JP2P72HYT3CME (+ (get-balance 'SP87NT88HVA7SR9JKFSM9XKDS59JP2P72HYT3CME) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u7) 'SP2EWA4BE511DK2KKK71YF1NHFM5NZR3Y2Z1091R1))
      (map-set token-count 'SP2EWA4BE511DK2KKK71YF1NHFM5NZR3Y2Z1091R1 (+ (get-balance 'SP2EWA4BE511DK2KKK71YF1NHFM5NZR3Y2Z1091R1) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u8) 'SP13K083XS2DYEQ7PR7KZFF3SQGH50V3WMN3AS3DH))
      (map-set token-count 'SP13K083XS2DYEQ7PR7KZFF3SQGH50V3WMN3AS3DH (+ (get-balance 'SP13K083XS2DYEQ7PR7KZFF3SQGH50V3WMN3AS3DH) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u9) 'SP23B41ZYGNSJ22JCWJJ4P39KQC5RW10E1R4Q8PJW))
      (map-set token-count 'SP23B41ZYGNSJ22JCWJJ4P39KQC5RW10E1R4Q8PJW (+ (get-balance 'SP23B41ZYGNSJ22JCWJJ4P39KQC5RW10E1R4Q8PJW) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u10) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u11) 'SP1SX5YDFDYWW16SMD1PQ5KS1QV3XK5S27PJPJMTG))
      (map-set token-count 'SP1SX5YDFDYWW16SMD1PQ5KS1QV3XK5S27PJPJMTG (+ (get-balance 'SP1SX5YDFDYWW16SMD1PQ5KS1QV3XK5S27PJPJMTG) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u12) 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
      (map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u13) 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P))
      (map-set token-count 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P (+ (get-balance 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u14) 'SP31YFWM5E8F4ZPYQY6H5JJDX441VF0Z8MB7DJ535))
      (map-set token-count 'SP31YFWM5E8F4ZPYQY6H5JJDX441VF0Z8MB7DJ535 (+ (get-balance 'SP31YFWM5E8F4ZPYQY6H5JJDX441VF0Z8MB7DJ535) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u15) 'SP2SVVKFMHAGSQKFZ18PPQM7DK0HPRNT55ADKJZ8C))
      (map-set token-count 'SP2SVVKFMHAGSQKFZ18PPQM7DK0HPRNT55ADKJZ8C (+ (get-balance 'SP2SVVKFMHAGSQKFZ18PPQM7DK0HPRNT55ADKJZ8C) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u16) 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ))
      (map-set token-count 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ (+ (get-balance 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u17) 'SP3FNYX415NC2NBVEK2GQ3K22SV7BAQEQXX1AE1RC))
      (map-set token-count 'SP3FNYX415NC2NBVEK2GQ3K22SV7BAQEQXX1AE1RC (+ (get-balance 'SP3FNYX415NC2NBVEK2GQ3K22SV7BAQEQXX1AE1RC) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u18) 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W))
      (map-set token-count 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W (+ (get-balance 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u19) 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE))
      (map-set token-count 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE (+ (get-balance 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u20) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u21) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u22) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? dogeception-x-arnofromearth (+ last-nft-id u23) 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
      (map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))

      (var-set last-id (+ last-nft-id u24))
      (var-set airdrop-called true)
      (ok true))))