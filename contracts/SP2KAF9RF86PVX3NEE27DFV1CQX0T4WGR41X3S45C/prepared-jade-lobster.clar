(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait token-trait .token-trait.token-trait)
(use-trait lookup-trait .lookup-trait.lookup-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-NOT-APPROVED u402)
(define-constant ERR-INVALID-TRADE u103)
(define-constant ERR-INVALID-STAKE u104)
(define-constant ERR-MONKEY-LISTED u105)
(define-constant ERR-ITEM-PRICE-TOO-LOW u102)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var admin principal 'SPJ6EME4DQ8242ZDR56VAVB7R9PAY0ZBV1640EQX)
(define-data-var blocks-per-token uint u3)
(define-data-var staking-fees (list 1000 uint) (list u3000000 u2000000))
(define-data-var unstaking-fees (list 1000 uint) (list u3000000 u2000000))
(define-data-var payout-addresses (list 1000 principal) (list 'SPJ6EME4DQ8242ZDR56VAVB7R9PAY0ZBV1640EQX 'SP194TKVC1QE8PQ8J97A7DSPFPQJTQVN7JDH8HHC6))
(define-data-var approved-principals (list 1000 principal) (list ))
(define-data-var staked (list 5000 principal) (list ))
(define-data-var shutoff-valve bool false)
(define-data-var removing-item-id uint u0)
(define-data-var token-address principal .test-coin)

(define-map stakes { staker: principal, collection: principal, item: uint } { stake-time: uint, points: uint, multiplier: uint })
(define-map pool { staker: principal } { stake-time: uint, lifetime-points: uint, points-balance: uint, total-multiplier: uint })
(define-map staked-nfts { staker: principal, collection: principal } { ids: (list 5000 uint) })
(define-map owners { collection: principal, item: uint } { owner: principal })
(define-map listed { collection: principal, item: uint } { listing: bool })

(define-public (stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (points (if (is-some (map-get? stakes { staker: tx-sender, collection: (contract-of collection), item: item })) (unwrap-panic (get points (map-get? stakes { staker: tx-sender, collection: (contract-of collection), item: item }))) u0))
        (balance (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get points-balance (map-get? pool { staker: tx-sender }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get lifetime-points (map-get? pool { staker: tx-sender }))) u0))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (total-multiplier (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get total-multiplier (map-get? pool { staker: tx-sender }))) u0))
        (block block-height)
        (prev-time (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get stake-time (map-get? pool { staker: tx-sender }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-token)))
        (ids (get-staked-nfts tx-sender (contract-of collection)))
    )
    (asserts! (is-eq false (get-listed (contract-of collection) item)) (err ERR-MONKEY-LISTED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get approved-principals) (contract-of collection))) (err ERR-NOT-APPROVED))
    (asserts! (is-some (index-of (var-get approved-principals) (contract-of lookup-table))) (err ERR-NOT-APPROVED))
    (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? collection get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
    (begin 
        (if (> (unwrap-panic (get-staking-fee)) u0)
          (begin
            (print (map pay (var-get payout-addresses) (var-get staking-fees)))
            (map-set stakes { staker: tx-sender, collection: (contract-of collection), item: item } { stake-time: block, points: points, multiplier: multiplier })
            (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: lifetime, points-balance: (+ balance points-added), total-multiplier: (+ total-multiplier multiplier) })
            ;; (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: (+ lifetime points-added), points-balance: (+ balance points-added), total-multiplier: (+ total-multiplier multiplier) })
            (map-set owners { collection: (contract-of collection), item: item } { owner: tx-sender })
            (map-set staked-nfts { staker: tx-sender, collection: (contract-of collection) }
              { ids: (unwrap-panic (as-max-len? (append ids item) u5000)) }
            )
          )
          (begin
            (map-set stakes { staker: tx-sender, collection: (contract-of collection), item: item } { stake-time: block, points: points, multiplier: multiplier })
            (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: lifetime, points-balance: (+ balance points-added), total-multiplier: (+ total-multiplier multiplier) })
            (map-set owners { collection: (contract-of collection), item: item } { owner: tx-sender })
            (map-set staked-nfts { staker: tx-sender, collection: (contract-of collection) }
              { ids: (unwrap-panic (as-max-len? (append ids item) u5000)) }
            )
          )
        )
        (print (map-get? pool { staker: tx-sender }))
        (print (map-get? stakes { staker: tx-sender, collection: (contract-of collection), item: item }))
        (ok true)
    )
    )
)

(define-public (unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (owner (unwrap-panic (get owner (map-get? owners { collection: (contract-of collection), item: item }))))
        (block block-height)
        (points (if (is-some (map-get? stakes { staker: tx-sender, collection: (contract-of collection), item: item })) (unwrap-panic (get points (map-get? stakes { staker: tx-sender, collection: (contract-of collection), item: item }))) u0))
        (balance (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get points-balance (map-get? pool { staker: tx-sender }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get lifetime-points (map-get? pool { staker: tx-sender }))) u0))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (total-multiplier (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get total-multiplier (map-get? pool { staker: tx-sender }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get stake-time (map-get? pool { staker: tx-sender }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-token)))
        (ids (get-staked-nfts owner (contract-of collection)))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get approved-principals) (contract-of collection))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get approved-principals) (contract-of lookup-table))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq owner tx-sender) (err ERR-NOT-AUTHORIZED))
    (var-set removing-item-id item)
    (begin 
        (print points)
        (if (> (unwrap-panic (get-unstaking-fee)) u0)
          (begin
            (print (map pay (var-get payout-addresses) (var-get unstaking-fees)))
            (map-set stakes { staker: tx-sender, collection: (contract-of collection), item: item } { stake-time: block, points: points-added, multiplier: multiplier  })
        
            (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: lifetime, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
            
            (map-set staked-nfts { staker: tx-sender, collection: (contract-of collection) }
              { ids: (filter remove-item-id ids) }
            )
          )
          (begin
            (map-set stakes { staker: tx-sender, collection: (contract-of collection), item: item } { stake-time: block, points: points-added, multiplier: multiplier  })
        
            (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: lifetime, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
            
            (map-set staked-nfts { staker: tx-sender, collection: (contract-of collection) }
              { ids: (filter remove-item-id ids) }
            )
          )
        )
        
        (print (map-get? stakes { staker: tx-sender, collection: (contract-of collection), item: item }))
        (print (map-get? pool { staker: tx-sender }))
        (ok true)
    )
    )
)

(define-public (set-listed (collection principal) (item uint))
  (begin
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get approved-principals) collection)) (err ERR-NOT-APPROVED))
    (asserts! (is-eq contract-caller collection) (err ERR-NOT-AUTHORIZED))
    (map-set listed { collection: collection, item: item } { listing: true })
    (ok true)
  )
)

(define-public (set-unlisted (collection principal) (item uint))
  (begin
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get approved-principals) collection)) (err ERR-NOT-APPROVED))
    (asserts! (is-eq contract-caller collection) (err ERR-NOT-AUTHORIZED))
    (map-set listed { collection: collection, item: item } { listing: false })
    (ok true)
  )
)

(define-read-only (get-listed (collection principal) (item uint))
  (default-to false
    (get listing (map-get? listed {collection: collection, item: item}))
  )
)

(define-private (remove-item-id (item-id uint))
  (if (is-eq item-id (var-get removing-item-id))
    false
    true
  )
)

(define-public (collect (fungible <token-trait>))
    (let (
        (block block-height)
        (owner tx-sender)
        (balance (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get points-balance (map-get? pool { staker: tx-sender }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get lifetime-points (map-get? pool { staker: tx-sender }))) u0))
        (total-multiplier (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get total-multiplier (map-get? pool { staker: tx-sender }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get stake-time (map-get? pool { staker: tx-sender }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-token)))
        (to-collect (+ balance points-added))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get token-address) (contract-of fungible)) (err ERR-NOT-AUTHORIZED))
    (begin 
        (try! (as-contract (contract-call? fungible collect owner to-collect)))
        
        (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: (+ lifetime points-added), points-balance: u0, total-multiplier: total-multiplier })
        
        (print (map-get? pool { staker: tx-sender }))
        (ok true)
    )
    )
)

(define-public (admin-stake (owner principal) (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (block block-height)
        (points (if (is-some (map-get? stakes { staker: owner, collection: (contract-of collection), item: item })) (unwrap-panic (get points (map-get? stakes { staker: owner, collection: (contract-of collection), item: item }))) u0))
        (balance (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get points-balance (map-get? pool { staker: owner }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get lifetime-points (map-get? pool { staker: owner }))) u0))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (total-multiplier (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get total-multiplier (map-get? pool { staker: owner }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get stake-time (map-get? pool { staker: owner }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-token)))
        (ids (get-staked-nfts owner (contract-of collection)))
    )
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (begin 
        (print points)
        (map-set stakes { staker: owner, collection: (contract-of collection), item: item } { stake-time: block, points: points-added, multiplier: multiplier  })
        (map-set pool { staker: owner } { stake-time: block, lifetime-points: lifetime, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
        (map-set staked-nfts { staker: owner, collection: (contract-of collection) }
          { ids: (filter remove-item-id ids) }
        )

        (print (map-get? stakes { staker: owner, collection: (contract-of collection), item: item }))
        (print (map-get? pool { staker: owner }))
        (ok true)
    )
    )
)

(define-public (admin-unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (owner (unwrap-panic (get owner (map-get? owners { collection: (contract-of collection), item: item }))))
        (block block-height)
        (points (if (is-some (map-get? stakes { staker: owner, collection: (contract-of collection), item: item })) (unwrap-panic (get points (map-get? stakes { staker: owner, collection: (contract-of collection), item: item }))) u0))
        (balance (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get points-balance (map-get? pool { staker: owner }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get lifetime-points (map-get? pool { staker: owner }))) u0))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (total-multiplier (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get total-multiplier (map-get? pool { staker: owner }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get stake-time (map-get? pool { staker: owner }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-token)))
        (ids (get-staked-nfts owner (contract-of collection)))
    )
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get approved-principals) (contract-of collection))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get approved-principals) (contract-of lookup-table))) (err ERR-NOT-AUTHORIZED))
    (var-set removing-item-id item)
    (begin 
        (print points)
        (map-set stakes { staker: owner, collection: (contract-of collection), item: item } { stake-time: block, points: points-added, multiplier: multiplier  })
        
        (map-set pool { staker: owner } { stake-time: block, lifetime-points: lifetime, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
        
        (map-set staked-nfts { staker: owner, collection: (contract-of collection) }
          { ids: (filter remove-item-id ids) }
        )
        (print (map-get? stakes { staker: owner, collection: (contract-of collection), item: item }))
        (print (map-get? pool { staker: owner }))
        (ok true)
    )
    )
)

(define-read-only (check-staker (staker principal))
    (ok (map-get? pool { staker: staker }))
)

(define-read-only (check-collect (staker principal))
    (let (
        (block block-height)
        (owner staker)
        (balance (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get points-balance (map-get? pool { staker: owner }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get lifetime-points (map-get? pool { staker: owner }))) u0))
        (total-multiplier (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get total-multiplier (map-get? pool { staker: owner }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get stake-time (map-get? pool { staker: owner }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-token)))
        (to-collect (+ balance points-added))
    )
        to-collect
    )
)

(define-read-only (staking-live)
    (not (var-get shutoff-valve))
)

(define-public (pay (receiver principal) (price uint))
  (begin
    (try! (stx-transfer? price tx-sender receiver))
    (ok true)
  )
)

(define-public (principal-add (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set approved-principals (unwrap-panic (as-max-len? (append (var-get approved-principals) address) u1000))))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-staked-nfts (staker principal) (address principal))
  (default-to
    (list )
    (get ids (map-get? staked-nfts { staker: staker, collection: address }))
  )
)

(define-read-only (get-staking-fee)
    (ok (fold + (var-get staking-fees) u0))
)

(define-read-only (get-unstaking-fee)
    (ok (fold + (var-get unstaking-fees) u0))
)

(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (shutoff-switch (switch bool))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set shutoff-valve switch))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (change-emissions (blocks uint))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set blocks-per-token blocks))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (staking-fee-change (amounts (list 1000 uint)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set staking-fees amounts))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (unstaking-fee-change (amounts (list 1000 uint)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set unstaking-fees amounts))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (token-change (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set token-address address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (payout-addresses-change (addresses (list 1000 principal)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set payout-addresses addresses))
    (err ERR-NOT-AUTHORIZED)
  )
)