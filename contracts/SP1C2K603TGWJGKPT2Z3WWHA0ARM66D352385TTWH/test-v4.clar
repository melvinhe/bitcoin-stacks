(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait token-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.token-trait.token-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-constant ERR-NOT-AUTHORIZED u404)
(define-constant ERR-PAYOUT-LEN-MISMATCH u402)
(define-constant ERR-EMISSION-TOO-HIGH u403)
(define-constant ERR-ITEM-LISTED u405)
(define-constant ERR-NOT-WHITELISTED u401)
(define-constant ERR-CONTRACT-NOT-AUTHORIZED u407)
(define-constant ERR-NOT-CALLED-BY-HELPER u408)
(define-constant ERR-FEES-TOO-HIGH u504)
(define-constant ERR-MIGRATION-NOT-AUTHORIZED u500)
(define-constant ERR-BLACKLISTED u666)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant EMISSION-LIMIT u29)

(define-data-var admin principal tx-sender)
(define-data-var collections-whitelist (list 100 principal) (list ))
(define-data-var multipliers-whitelist (list 100 principal) (list ))
(define-data-var blacklist (list 1000 principal) (list ))
(define-data-var shutoff-valve bool false)
(define-data-var removing-item-id uint u0)
(define-data-var removing-collection principal (as-contract tx-sender))
(define-data-var token-address principal .test-token)
(define-data-var migration-contract principal (as-contract tx-sender))
(define-data-var use-helper bool true)
(define-data-var staking-helper principal (as-contract tx-sender))

(define-map collection-pool { staker: principal, collection: principal } { stake-time: uint, points-balance: uint, total-multiplier: uint })
(define-map staker-info { staker: principal } { collections: (list 100 principal), lifetime-points: uint})
(define-map staked-nfts { staker: principal, collection: principal } { ids: (list 2500 uint) })
(define-map owners { collection: principal, item: uint } { owner: principal })
(define-map approved-collections { collection: principal} { staking-fees: (list 100 uint), unstaking-fees: (list 100 uint), addresses: (list 100 principal), blocks-per-token: uint, multiplier: principal, custodial: bool, prev-blocks-per-token: uint, halve-block: uint})
(define-map listed { collection: principal, item: uint } { listing: bool })

;;read-only functions
(define-read-only (get-collection (collection principal))
    (default-to 
      { staking-fees: (list ), unstaking-fees: (list ), addresses: (list ), blocks-per-token: u0, multiplier: (as-contract tx-sender), custodial: false , prev-blocks-per-token: u0, halve-block: u0}
      (some (unwrap-panic (map-get? approved-collections { collection: collection })))
    )
)

(define-read-only (get-collection-whitelist)
    (ok (var-get collections-whitelist))
)

(define-read-only (get-multiplier-whitelist)
    (ok (var-get multipliers-whitelist))
)

(define-read-only (check-staker (staker principal))
    (default-to 
      {collections: (list ), lifetime-points: u0} 
      (map-get? staker-info { staker: staker })
    )
)

(define-read-only (get-staking-fee (collection principal))
    (default-to u0 (some (fold + (get staking-fees (get-collection collection)) u0)))
)

(define-read-only (get-unstaking-fee (collection principal))
    (default-to u0 (some (fold + (get unstaking-fees (get-collection collection)) u0)))
)

(define-read-only (get-payout-addresses (collection principal))
    (default-to (list ) (some (get addresses (get-collection collection))))
)

(define-read-only (get-blocks-per-token (collection principal))
    (default-to u0 (some (get blocks-per-token (get-collection collection))))
)

(define-read-only (get-pool (staker principal) (collection principal))
    (default-to 
    { stake-time: block-height, points-balance: u0, total-multiplier: u0 }
    (map-get? collection-pool  { staker: tx-sender, collection: collection })
    )
)

(define-read-only (check-collect (collection principal) (staker principal))
    (let (
        (pool (get-pool tx-sender collection))
        (block block-height)
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (blocks-per-token (get-blocks-per-token collection))
        (halve (get halve-block (get-collection collection)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (to-collect (+ balance points-added))       
    )
        to-collect
  )
)

(define-read-only (get-staked-nfts (staker principal) (collection principal))
  (default-to
    (list )
    (get ids (map-get? staked-nfts { staker: staker, collection: collection }))
  )
)

(define-read-only (get-listed (collection principal) (item uint))
  (default-to false
    (get listing (map-get? listed {collection: collection, item: item}))
  )
)

(define-read-only (get-migration-contract)
    (var-get migration-contract)
)

;;public functions
(define-public (stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (collection-contract (contract-of collection))
        (pool (get-pool tx-sender collection-contract))
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (block block-height)
        (blocks-per-token (get-blocks-per-token collection-contract))
        (halve (get halve-block (get-collection collection-contract)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection-contract)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (ids (get-staked-nfts tx-sender collection-contract))
        (fees (get-staking-fee collection-contract))
        (payouts (get-payout-addresses collection-contract))
        (custodial (get custodial (get-collection collection-contract)))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get collections-whitelist) collection-contract)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-some (index-of (var-get multipliers-whitelist) (contract-of lookup-table))) (err ERR-NOT-WHITELISTED))
    (asserts! (not (is-some (index-of (var-get blacklist) collection-contract))) (err ERR-BLACKLISTED))
    (asserts! (not (is-some (index-of (var-get blacklist) tx-sender))) (err ERR-BLACKLISTED))
    (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? collection get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq false (get-listed (contract-of collection) item)) (err ERR-ITEM-LISTED))
    (if (var-get use-helper) (asserts! (is-eq contract-caller (var-get staking-helper)) (err ERR-NOT-CALLED-BY-HELPER)) true)   
    (begin 
        (if (> fees u0)
          (begin
            (print (map pay payouts (get staking-fees (get-collection collection-contract ))))
          )
          (list (ok true))
        )
        (if (is-eq custodial true) (try! (contract-call? collection transfer item tx-sender (as-contract tx-sender))) true)
        (set-staker-collections tx-sender collection-contract)
        (map-set collection-pool { staker: tx-sender, collection: collection-contract } { stake-time: block, points-balance: (+ balance points-added), total-multiplier: (+ total-multiplier multiplier) })
        (map-set owners { collection: collection-contract, item: item } { owner: tx-sender })
        (map-set staked-nfts { staker: tx-sender, collection: collection-contract}
          { ids: (unwrap-panic (as-max-len? (append ids item) u2500)) }
        )
        (print {
          action: "stake",
          staker: (check-staker tx-sender),
          collection-pool: (map-get? collection-pool { staker: tx-sender, collection: collection-contract })
        })
        (ok true)
    )
    )
)

(define-public (unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (collection-contract (contract-of collection))
        (pool (get-pool tx-sender collection-contract))
        (owner (unwrap-panic (get owner (map-get? owners { collection: collection-contract, item: item }))))
        (block block-height)
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (blocks-per-token (get-blocks-per-token collection-contract))
        (halve (get halve-block (get-collection collection-contract)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection-contract)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (ids (get-staked-nfts owner collection-contract))
        (fees (get-unstaking-fee collection-contract))
        (payouts (get-payout-addresses collection-contract))
        (staker-collections (get collections (check-staker tx-sender)))
        (custodial (get custodial (get-collection collection-contract)))        
    )
    (asserts! (is-some (index-of (var-get collections-whitelist) collection-contract)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-some (index-of (var-get multipliers-whitelist) (contract-of lookup-table))) (err ERR-NOT-WHITELISTED))
    (if (var-get use-helper) (asserts! (is-eq contract-caller (var-get staking-helper)) (err ERR-NOT-CALLED-BY-HELPER)) true)   
    (if custodial
      (asserts! (is-eq owner tx-sender) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? collection get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
    )
    (var-set removing-item-id item)
    (begin 
        (if (> fees u0)
          (begin
            (print (map pay payouts (get unstaking-fees (get-collection collection-contract ))))
          )
          (list (ok true))
        )
        (if (is-eq custodial true) (try! (as-contract (contract-call? collection transfer item (as-contract tx-sender) owner ))) true)
        (map-set collection-pool { staker: tx-sender, collection: collection-contract } { stake-time: block, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
        (map-set staked-nfts { staker: tx-sender, collection: collection-contract }
          { ids: (filter remove-item-id ids) }
        )
        (print {
          action: "unstake",
          staker: (check-staker tx-sender),
          collection-pool: (map-get? collection-pool { staker: tx-sender, collection: collection-contract })
        })
        (ok true)
    )
    )
)

(define-public (collect (collection principal) (fungible <token-trait>))
  (let (
      (block block-height)
      (owner tx-sender)
      (info (check-staker tx-sender))
      (to-collect (check-collect collection tx-sender))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get token-address) (contract-of fungible)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (is-some (index-of (var-get blacklist) tx-sender))) (err ERR-BLACKLISTED))
    (asserts! (not (is-some (index-of (var-get blacklist) collection))) (err ERR-BLACKLISTED))
    (begin
      (try! (as-contract (contract-call? fungible collect owner to-collect)))
      (map-set staker-info { staker: tx-sender} (merge (check-staker tx-sender) { lifetime-points: (+ (get lifetime-points info) to-collect)}))
      (map-set collection-pool { staker: tx-sender, collection: collection }  (merge (unwrap-panic (map-get? collection-pool { staker: tx-sender, collection: collection })) { stake-time: block-height, points-balance: u0}))
    )
    (print {
      action: "collect",
      collection: collection,
      amount: to-collect,
      staker: (get-pool tx-sender collection)
    })
   (ok true)
  )
)

(define-public (pay (receiver principal) (price uint))
  (begin
    (try! (stx-transfer? price tx-sender receiver))
    (ok true)
  )
)

(define-public (set-listed (collection principal) (item uint))
  (begin
    (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-eq contract-caller collection) (err ERR-NOT-AUTHORIZED))
    (map-set listed { collection: collection, item: item } { listing: true })
    (ok true)
  )
)

(define-public (set-unlisted (collection principal) (item uint))
  (begin
    (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-eq contract-caller collection) (err ERR-NOT-AUTHORIZED))
    (map-set listed { collection: collection, item: item } { listing: false })
    (ok true)
  )
)

;;admin-only and helper functions
(define-public (whitelist-collection 
  (collection principal) (staking-fees (list 100 uint)) (unstaking-fees (list 100 uint)) (payouts (list 100 principal)) (blocks-per-token uint) (multiplier principal) (custodial bool)
  )
  (begin 
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (<= (fold + staking-fees u0) u10000000) (err ERR-FEES-TOO-HIGH))
    (asserts! (<= (fold + unstaking-fees u0) u10000000) (err ERR-FEES-TOO-HIGH))
    (asserts! (>= blocks-per-token EMISSION-LIMIT) (err ERR-EMISSION-TOO-HIGH))
    (try! (approve-collection collection))
    (try! (approve-multiplier multiplier))
    (map-set approved-collections 
      { collection: collection } 
      {staking-fees: staking-fees, unstaking-fees: unstaking-fees, addresses: payouts, blocks-per-token: blocks-per-token, multiplier: multiplier, custodial: custodial, prev-blocks-per-token: u0, halve-block: u0})
    (print {
      action: "whitelist-collection",
      collection: (get-collection collection),
      whitelist: (var-get collections-whitelist)
    })
    (ok true))
)

(define-public (admin-stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (collection-contract (contract-of collection))
        (pool (get-pool tx-sender collection-contract))
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (block block-height)
        (blocks-per-token (get-blocks-per-token collection-contract))
        (halve (get halve-block (get-collection collection-contract)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection-contract)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (ids (get-staked-nfts tx-sender collection-contract))
        (fees (get-staking-fee collection-contract))
        (payouts (get-payout-addresses collection-contract))
        (custodial (get custodial (get-collection collection-contract)))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get collections-whitelist) collection-contract)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-some (index-of (var-get multipliers-whitelist) (contract-of lookup-table))) (err ERR-NOT-WHITELISTED))
    (asserts! (not (is-some (index-of (var-get blacklist) collection-contract))) (err ERR-BLACKLISTED))
    (asserts! (not (is-some (index-of (var-get blacklist) tx-sender))) (err ERR-BLACKLISTED))
    (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? collection get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (or (is-eq contract-caller (var-get staking-helper)) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
    (asserts! (or (var-get use-helper) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
    (begin 
        (if (is-eq custodial true) (try! (contract-call? collection transfer item tx-sender (as-contract tx-sender))) true)
        (set-staker-collections tx-sender collection-contract)
        (map-set collection-pool { staker: tx-sender, collection: collection-contract } { stake-time: block, points-balance: (+ balance points-added), total-multiplier: (+ total-multiplier multiplier) })
        (map-set owners { collection: collection-contract, item: item } { owner: tx-sender })
        (map-set staked-nfts { staker: tx-sender, collection: collection-contract}
          { ids: (unwrap-panic (as-max-len? (append ids item) u2500)) }
        )
        (print {
          action: "stake",
          staker: (check-staker tx-sender),
          collection-pool: (map-get? collection-pool { staker: tx-sender, collection: collection-contract })
        })
        (ok true)
    )
    )
)

(define-public (admin-unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (collection-contract (contract-of collection))
        (owner (unwrap-panic (get owner (map-get? owners { collection: collection-contract, item: item }))))
        (pool (get-pool owner collection-contract))
        (block block-height)
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (blocks-per-token (get-blocks-per-token collection-contract))
        (halve (get halve-block (get-collection collection-contract)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection-contract)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (ids (get-staked-nfts owner collection-contract))
        (custodial (get custodial (get-collection collection-contract)))
        (staker-collections (get collections (check-staker owner)))
    )
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (var-set removing-item-id item)
    (var-set removing-collection (contract-of collection))
    (begin 
        (if (is-eq custodial true) (try! (as-contract (contract-call? collection transfer item (as-contract tx-sender) owner ))) true)
        (map-set collection-pool { staker: owner, collection: collection-contract } { stake-time: block, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
        (map-set staked-nfts { staker: owner, collection: collection-contract }
          { ids: (filter remove-item-id ids) }
        )
        (print {
          action: "admin-unstake",
          staker: (check-staker owner),
          collection-pool: (map-get? collection-pool { staker: owner, collection: collection-contract })
        })
        (ok true)
    )
    )
)

;; halve the emission for all collections
(define-public (halving)
    (let (
          (collections (unwrap-panic (get-collection-whitelist)))
        ) 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (map halve-emission collections)
        (ok (print { action: "halving" }))
    )
)

;; used from helper to collect bonus rewards for stakers
(define-public (mint-sp (fungible <token-trait>) (amount uint) (recipient principal))
  (begin 
      (asserts! (var-get use-helper) (err ERR-CONTRACT-NOT-AUTHORIZED))
      (asserts! (is-eq contract-caller (var-get staking-helper)) (err ERR-CONTRACT-NOT-AUTHORIZED))
      (asserts! (is-eq (var-get token-address) (contract-of fungible)) (err ERR-NOT-AUTHORIZED))
      (try! (as-contract (contract-call? fungible collect recipient amount)))
      (ok true)
  )
)

;; approve a collection contract for staking
(define-public (approve-collection (collection principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set collections-whitelist (unwrap-panic (as-max-len? (append (var-get collections-whitelist) collection) u100))))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; approve a multiplier contract for staking
(define-public (approve-multiplier (multiplier principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set multipliers-whitelist (unwrap-panic (as-max-len? (append (var-get multipliers-whitelist) multiplier) u100))))
    (err ERR-NOT-AUTHORIZED)
  )
)

;;change contract admin
(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; security function: admins can turn off stake and collect functions for all collections
(define-public (shutoff-switch (switch bool))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set shutoff-valve switch))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; change staking fees for a specific collection
(define-public (staking-fee-change (collection principal) (amounts (list 100 uint)))
    (let (
          (payouts (get-payout-addresses collection))
        ) 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (len payouts) (len amounts)) (err ERR-PAYOUT-LEN-MISMATCH))
        (asserts! (<= (fold + amounts u0) u10000000) (err ERR-FEES-TOO-HIGH))
        (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
        (map-set approved-collections { collection: collection} (merge (get-collection collection) {staking-fees: amounts}))
        (ok     
        (print {
          action: "staking-fee-change",
          collection: (get-collection collection)
        }))
    )
)

;; change unstaking fees for a specific collection
(define-public (unstaking-fee-change (collection principal) (amounts (list 100 uint)))
    (let (
          (payouts (get-payout-addresses collection))
        ) 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (len payouts) (len amounts)) (err ERR-PAYOUT-LEN-MISMATCH))
        (asserts! (<= (fold + amounts u0) u10000000) (err ERR-FEES-TOO-HIGH))
        (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
        (map-set approved-collections { collection: collection} (merge (get-collection collection) {unstaking-fees: amounts}))
        (ok
        (print {
          action: "unstaking-fee-change",
          collection: (get-collection collection)
        }))
    )
)

;; change the payouts for a specific collection
(define-public (payout-addresses-change (collection principal) (addresses (list 100 principal)))
    (let (
          (amounts (get staking-fees (get-collection collection)))
        ) 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (len addresses) (len amounts)) (err ERR-PAYOUT-LEN-MISMATCH))
        (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
        (ok (map-set approved-collections { collection: collection} (merge (get-collection collection) {addresses: addresses})))
    )
)

;; change the emission for a specific collection
(define-public (blocks-per-token-change (collection principal) (blocks uint))
    (begin 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (>= blocks EMISSION-LIMIT) (err ERR-EMISSION-TOO-HIGH))
        (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
        (ok (map-set approved-collections { collection: collection} (merge (get-collection collection) {blocks-per-token: blocks, prev-blocks-per-token: (get blocks-per-token (get-collection collection)), halve-block: block-height})))
    )
)

;; change the authorized staking token
(define-public (token-change (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set token-address address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; change the authorized migration contract
(define-public (migration-change (migration principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set migration-contract migration))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (helper-change (helper principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set staking-helper helper))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (toggle-use-helper (switch bool))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set use-helper switch))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; add an address or collection from blacklist
(define-public (blacklist-address (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set blacklist (unwrap-panic (as-max-len? (append (var-get blacklist) address) u100))))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; remove an address or collection from blacklist
(define-public (unblacklist-address (address principal))
  (begin 
    (var-set removing-collection address)
    (if (is-eq tx-sender (var-get admin))
      (ok (var-set blacklist (filter remove-collection (var-get blacklist))))
      (err ERR-NOT-AUTHORIZED)
    ))
)

;;private functions
(define-private (halve-emission (collection principal))
    (let (
          (stakable (get-collection collection))
          (blocks (get blocks-per-token stakable))
        ) 
        (map-set approved-collections {collection: collection} (merge stakable { blocks-per-token: (* blocks u2), prev-blocks-per-token: blocks, halve-block: block-height}))
    )
)

(define-private (set-staker-collections (staker principal) (collection principal))
  (let (
    (info (check-staker staker))
    (staker-collections (get collections info)) 
    )
    (if (not (is-some (index-of staker-collections collection)))
      (map-set staker-info { staker: staker } (merge info { collections: (unwrap-panic (as-max-len? (append staker-collections collection) u100)) }))   
      true
    )
  )
)

(define-private (remove-item-id (item-id uint))
  (if (is-eq item-id (var-get removing-item-id))
    false
    true
  )
)

(define-private (remove-collection (collection principal))
  (if (is-eq collection (var-get removing-collection))
      false
      true  
    )
)

;;migration functions
(define-public (update-lifetime (staker principal) (lifetime uint))
(let (
  (info (check-staker staker))
  (life-points (get lifetime-points info))
)
  (asserts! (or (is-eq contract-caller (var-get migration-contract)) (is-eq contract-caller (var-get staking-helper))) (err ERR-MIGRATION-NOT-AUTHORIZED))
  (map-set staker-info {staker: staker} (merge info { lifetime-points: (+ life-points lifetime)}))
  (ok (print {
        action: "update-lifetime",
        lifetime-points: (+ life-points lifetime)}))
))

;;init actions
(whitelist-collection 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u29 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bull-multipliers true)
(whitelist-collection 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u29 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bear-multipliers true)
(whitelist-collection 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u29 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.whale-multipliers true)
(whitelist-collection 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-goats (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u29 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.goat-multipliers true)
(try! (contract-call? .test-token principal-add (as-contract tx-sender)))