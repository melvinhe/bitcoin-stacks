;; santa-claus-is-comin-to-town-single
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token santa-claus-is-comin-to-town-single uint)

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
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)
(define-data-var total-price uint u10000000)
(define-data-var artist-address principal 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qmaua1H1JjfXzGQeiDpdUdzr7ysdHtPdcwTWS2LyhehLPA/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)
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
      (unwrap! (nft-mint? santa-claus-is-comin-to-town-single next-id tx-sender) next-id)
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
    (nft-burn? santa-claus-is-comin-to-town-single token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? santa-claus-is-comin-to-town-single token-id) false)))

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
  (ok (nft-get-owner? santa-claus-is-comin-to-town-single token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-root))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-locked)
  (ok (var-get locked)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

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

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? santa-claus-is-comin-to-town-single id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? santa-claus-is-comin-to-town-single id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? santa-claus-is-comin-to-town-single id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u0) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u1) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u2) 'SP2EMZSA1CQQCGJEQ9JSDBWBV0NFDJ59EH5P9E56V))
      (map-set token-count 'SP2EMZSA1CQQCGJEQ9JSDBWBV0NFDJ59EH5P9E56V (+ (get-balance 'SP2EMZSA1CQQCGJEQ9JSDBWBV0NFDJ59EH5P9E56V) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u3) 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D))
      (map-set token-count 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D (+ (get-balance 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u4) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u5) 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN))
      (map-set token-count 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN (+ (get-balance 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u6) 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168))
      (map-set token-count 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168 (+ (get-balance 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u7) 'SP22W7TM6NG3PJ2XVVND2E06D50K3DDNREBTKGFD3))
      (map-set token-count 'SP22W7TM6NG3PJ2XVVND2E06D50K3DDNREBTKGFD3 (+ (get-balance 'SP22W7TM6NG3PJ2XVVND2E06D50K3DDNREBTKGFD3) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u8) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u9) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u10) 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20))
      (map-set token-count 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 (+ (get-balance 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u11) 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0))
      (map-set token-count 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 (+ (get-balance 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u12) 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB))
      (map-set token-count 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB (+ (get-balance 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB) u1))
      (try! (nft-mint? santa-claus-is-comin-to-town-single (+ last-nft-id u13) 'SPFX4ACY288K7YMK2EWS6NF8EGSJ33GFZ7T01XBS))
      (map-set token-count 'SPFX4ACY288K7YMK2EWS6NF8EGSJ33GFZ7T01XBS (+ (get-balance 'SPFX4ACY288K7YMK2EWS6NF8EGSJ33GFZ7T01XBS) u1))

      (var-set last-id (+ last-nft-id u14))
      (var-set airdrop-called true)
      (ok true))))