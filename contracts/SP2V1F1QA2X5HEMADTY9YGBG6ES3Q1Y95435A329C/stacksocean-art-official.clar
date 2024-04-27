(impl-trait 'SP2V1F1QA2X5HEMADTY9YGBG6ES3Q1Y95435A329C.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token stacksocean-art-official uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant err-mint u600)

(define-constant COMM u200)

(define-constant DEPLOYER tx-sender)
(define-constant MAIN 'SP2V1F1QA2X5HEMADTY9YGBG6ES3Q1Y95435A329C)
(define-constant COMM_ADDR 'SP3ZRDNS9NXNVD1P0QNZ6STBC4B6XT0RXHA4F6APV)
(define-constant COMM_ADDR1 'SPVDTWPB2AHT63385BT3JENEM68VNFMGWADVDKWD)
(define-constant COMM_ADDR2 'SP1P1A6VNW2M05JB7FHG6EBBH1ZAB05XWRZABN1ZG)

;; Internal variables
(define-data-var mint-limit uint u5)
(define-data-var last-id uint u1)
(define-data-var total-price uint u1000000)
(define-data-var artist-address principal 'SP67RWGFXKEYFW3P16M15WR2Z3JV1M17V5FC06Q5)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmNMwWZULwpG7AZrLrPwGXMeYspBEAjoamtYSaqxjhTQqz/")
(define-data-var ipfs-change-enabled bool true)

(define-private (mint-many (orders (list 10 bool)))
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err err-no-more-nfts)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (total-commission1 (/ (* price COMM) u10000))
      (total-commission2 (/ (* price COMM) u10000))
      (total-artist (- price (+ total-commission total-commission1 total-commission2)))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender MAIN))
      (var-set last-id id-reached)
      (begin
        (var-set last-id id-reached)
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM_ADDR))
        (try! (stx-transfer? total-commission1 tx-sender COMM_ADDR1))
        (try! (stx-transfer? total-commission2 tx-sender COMM_ADDR2))
      )
    )
    (ok id-reached)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? stacksocean-art-official next-id tx-sender) next-id)
      (+ next-id u1)
    )
    next-id
  )
)

(define-public (claim)
  (mint-many (list true))
)

(define-public (claim-five)
  (mint-many (list true true true true true))
)

(define-public (claim-ten)
  (mint-many (list true true true true true true true true true true))
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set artist-address address))
  )
)

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set total-price price))
  )
)

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (begin
    (asserts! (and (var-get ipfs-change-enabled) (is-eq tx-sender DEPLOYER)) (err err-invalid-user))
    (ok (var-set ipfs-root new-ipfs-root))
  )
)

(define-public (freeze-ipfs-root)
  (begin
    (asserts! (and (var-get ipfs-change-enabled) (is-eq tx-sender DEPLOYER)) (err err-invalid-user))
    (ok (var-set ipfs-change-enabled false))
  )
)

(define-public (set-mint-limit (new-limit uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set mint-limit new-limit))
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err err-invalid-user))
    (nft-transfer? stacksocean-art-official token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacksocean-art-official token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))