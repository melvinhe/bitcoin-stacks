(define-constant POOL_ADDRESS 'SP1D8PR8F7BDFT1Q9DJFN3DJEGTXD6EFSFPEPQMBV)

(define-constant CONTRACT_ADDRESS (as-contract tx-sender))

(define-constant ERR_UNAUTHORIZED u1000)
(define-data-var price uint u90000)

(define-public (sell-nyc (amount uint))
    (begin
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        (try! (transfer-nyc amount contract-caller CONTRACT_ADDRESS))
        (ok true)
    )
)

(define-public (exit-nyc (amount uint))
    (begin 
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        (try! (as-contract (transfer-nyc amount CONTRACT_ADDRESS POOL_ADDRESS)))
        (ok true)
    )
)

(define-public (buy-nyc (amount uint))
    (let
        ((user contract-caller))
        (asserts! (not (is-auth-pool)) (err ERR_UNAUTHORIZED))
        (try! (stx-transfer? (* amount (var-get price)) user POOL_ADDRESS))
        (try! (as-contract (transfer-nyc amount CONTRACT_ADDRESS user)))
        (ok true)
    )
)

(define-public (change-price (newPrice uint)) 
    (begin
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        (var-set price newPrice)
        (ok true)
    )
)

(define-read-only (get-price)
    (ok (var-get price))
)

(define-read-only (get-remaining)
    (ok (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance (as-contract tx-sender)))
)

(define-read-only (get-contract-stx-balance)
  (stx-get-balance CONTRACT_ADDRESS)
)

(define-read-only (get-pool-nyc-balance)
  (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance POOL_ADDRESS)
)

(define-read-only (get-pool-stx-balance)
  (stx-get-balance POOL_ADDRESS)
)

(define-private (is-auth-pool)
  (is-eq contract-caller POOL_ADDRESS)
)

(define-private (transfer-nyc (amount uint) (from principal) (to principal))
    (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer amount from to none)
)

(define-private (get-balance (user principal))
    (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance user)
)

;; Thanks to Syvita
;; Buy $NYC from KCV DAO https://nyc.kcvdao.com