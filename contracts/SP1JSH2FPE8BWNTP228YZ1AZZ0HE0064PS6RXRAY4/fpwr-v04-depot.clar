(define-constant admin 'SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60)

(define-map balances principal uint)
(define-data-var total-rewards uint u0)
(define-data-var total-claimed uint u0)

(define-read-only (get-balance (user principal))
  (ok (map-get? balances user)))

(define-read-only (get-depot-info)
  {tokens: (contract-call? 'SP1JSH2FPE8BWNTP228YZ1AZZ0HE0064PS6RXRAY4.fpwr-v04 get-balance (as-contract tx-sender)),
   total-rewards: (var-get total-rewards),
   total-claimed: (var-get total-claimed)})

(define-public (claim)
  (let ((user tx-sender)
    (amount (default-to u0 (map-get? balances user))))
    (var-set total-claimed (+ amount (var-get total-claimed)))
    (if (> amount u0)
      (begin
        (map-set balances user u0)
        (as-contract (contract-call? 'SP1JSH2FPE8BWNTP228YZ1AZZ0HE0064PS6RXRAY4.fpwr-v04 transfer amount tx-sender user none))
      )
      (err u100))))

(define-private (add-reward (details {user: principal, amount: uint}))
  (let ((user-amount (default-to u0 (map-get? balances (get user details))))
    (reward-amount (get amount details)))
    (var-set total-rewards (+ reward-amount (var-get total-rewards)))
    (map-set balances (get user details) (+ reward-amount user-amount))))

(define-public (add-rewards (rewards (list 200 {user: principal, amount: uint})))
  (if (is-eq tx-sender admin)
    (ok (map add-reward rewards))
    (err u403)))

(define-public (update-reward-admin (new-admin principal))
  (if (is-eq tx-sender admin)
    (contract-call? 'SP1JSH2FPE8BWNTP228YZ1AZZ0HE0064PS6RXRAY4.fpwr-v04 update-reward-admin new-admin)
    (err u403)))
