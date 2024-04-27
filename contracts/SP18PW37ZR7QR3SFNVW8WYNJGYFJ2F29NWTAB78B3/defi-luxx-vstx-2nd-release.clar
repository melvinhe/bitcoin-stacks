;; defi-luxx-vstx-2nd-release
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token defi-luxx-vstx-2nd-release uint)

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
(define-data-var mint-limit uint u200)
(define-data-var last-id uint u1)
(define-data-var total-price uint u5000000)
(define-data-var artist-address principal 'SP18PW37ZR7QR3SFNVW8WYNJGYFJ2F29NWTAB78B3)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qmf451RDiz9StsVkJncqsMLgYMmZJFzF4XNRKk5xecoMK3/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u5)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

;; Mintpass Minting
(define-private (mint (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many orders)
      )
    )))

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
      (unwrap! (nft-mint? defi-luxx-vstx-2nd-release next-id tx-sender) next-id)
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
    (nft-burn? defi-luxx-vstx-2nd-release token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? defi-luxx-vstx-2nd-release token-id) false)))

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
  (ok (nft-get-owner? defi-luxx-vstx-2nd-release token-id)))

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
  (match (nft-transfer? defi-luxx-vstx-2nd-release id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? defi-luxx-vstx-2nd-release id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? defi-luxx-vstx-2nd-release id) (err ERR-NOT-FOUND)))
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

;; Extra functionality required for mintpass
(define-public (toggle-sale-state)
  (let 
    (
      ;; (premint (not (var-get premint-enabled)))
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set premint-enabled false)
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-public (enable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled true))))

(define-public (disable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled false))))

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))  

(map-set mint-passes 'SP2XM4YWN21CM8ZE1HZB0CSH59BD4J6Y82R0H00DA u3)
(map-set mint-passes 'SP12AB7VW90JJ8VFM3Z51DJWAKGH90F5S98AAX5XK u3)
(map-set mint-passes 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R u3)
(map-set mint-passes 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H u3)
(map-set mint-passes 'SP1PW5815RH57GT7NWM1VRSDNEWY7SEZ4KH2KDHDR u3)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u3)
(map-set mint-passes 'SPYJYXFQPKVBM25TCK83D8B69DXQFGFMXKWND821 u3)
(map-set mint-passes 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB u3)
(map-set mint-passes 'SP156DD4YJVBF1B8HQY25NEEZM1Q6JK0ZG82AW35P u3)
(map-set mint-passes 'SP13WNPYRQKR00B9R00Y4F1G5V09FE1DNN01DY70V u3)
(map-set mint-passes 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC u3)
(map-set mint-passes 'SP3CF4JWY44MWYFCC6BMV6K9NTEVCQ9CGE9EF1WZT u3)
(map-set mint-passes 'SPJT3WWPT4Q925GDE9BBZRC5MNZ3SMP8G7VMJSNS u3)
(map-set mint-passes 'SPFJ23VPTF5EKPJQ1AQV73CJPGJSH2HHGMB7D6H0 u3)
(map-set mint-passes 'SPBBRXNR9ZDDSBGJ8N2GF0C477927TK8J7AVFPTG u3)
(map-set mint-passes 'SP1EK2PBTZKZP45MY489V2M9G7JJTQCQ4GBR3REGY u3)
(map-set mint-passes 'SP1MSBV3NWY9WN6P1YFS4Z3N7V47W7SV6V8N94D6Q u3)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? defi-luxx-vstx-2nd-release (+ last-nft-id u0) 'SP27XJM6NQC5CX7KJ0S0XYMDEW5S2F3KXCZG6E682))
      (map-set token-count 'SP27XJM6NQC5CX7KJ0S0XYMDEW5S2F3KXCZG6E682 (+ (get-balance 'SP27XJM6NQC5CX7KJ0S0XYMDEW5S2F3KXCZG6E682) u1))
      (try! (nft-mint? defi-luxx-vstx-2nd-release (+ last-nft-id u1) 'SPN1FZQS9YHYT5TQFNKBJ2W76V7EZVPZAWDXA01T))
      (map-set token-count 'SPN1FZQS9YHYT5TQFNKBJ2W76V7EZVPZAWDXA01T (+ (get-balance 'SPN1FZQS9YHYT5TQFNKBJ2W76V7EZVPZAWDXA01T) u1))
      (try! (nft-mint? defi-luxx-vstx-2nd-release (+ last-nft-id u2) 'SP3TQM1VSMHETCZRBG5SR2PKZ4JRFS253BM3Y563A))
      (map-set token-count 'SP3TQM1VSMHETCZRBG5SR2PKZ4JRFS253BM3Y563A (+ (get-balance 'SP3TQM1VSMHETCZRBG5SR2PKZ4JRFS253BM3Y563A) u1))
      (try! (nft-mint? defi-luxx-vstx-2nd-release (+ last-nft-id u3) 'SP1E9874H9A8DM04P8MDXH6CWF7PFWZYCQ2EV9SK0))
      (map-set token-count 'SP1E9874H9A8DM04P8MDXH6CWF7PFWZYCQ2EV9SK0 (+ (get-balance 'SP1E9874H9A8DM04P8MDXH6CWF7PFWZYCQ2EV9SK0) u1))
      (try! (nft-mint? defi-luxx-vstx-2nd-release (+ last-nft-id u4) 'SP2YCWKYB5GCYTQM5RFERSXMZNBEZPNPBDVS9A88S))
      (map-set token-count 'SP2YCWKYB5GCYTQM5RFERSXMZNBEZPNPBDVS9A88S (+ (get-balance 'SP2YCWKYB5GCYTQM5RFERSXMZNBEZPNPBDVS9A88S) u1))
      (try! (nft-mint? defi-luxx-vstx-2nd-release (+ last-nft-id u5) 'SP276GKWN7R12Z0CE92SH30BD4X8H8WV8NZ6A6H6))
      (map-set token-count 'SP276GKWN7R12Z0CE92SH30BD4X8H8WV8NZ6A6H6 (+ (get-balance 'SP276GKWN7R12Z0CE92SH30BD4X8H8WV8NZ6A6H6) u1))
      (try! (nft-mint? defi-luxx-vstx-2nd-release (+ last-nft-id u6) 'SP3V8BF64NBJ06G1H3Y0SREER8PBH48ZC114GA0AW))
      (map-set token-count 'SP3V8BF64NBJ06G1H3Y0SREER8PBH48ZC114GA0AW (+ (get-balance 'SP3V8BF64NBJ06G1H3Y0SREER8PBH48ZC114GA0AW) u1))
      (try! (nft-mint? defi-luxx-vstx-2nd-release (+ last-nft-id u7) 'SP1FYDCRDMAGNPTWT235P9H466QBQMNZ8SZ3SPHTF))
      (map-set token-count 'SP1FYDCRDMAGNPTWT235P9H466QBQMNZ8SZ3SPHTF (+ (get-balance 'SP1FYDCRDMAGNPTWT235P9H466QBQMNZ8SZ3SPHTF) u1))

      (var-set last-id (+ last-nft-id u8))
      (var-set airdrop-called true)
      (ok true))))