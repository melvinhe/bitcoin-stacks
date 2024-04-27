(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u250)
(define-data-var commission-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender (var-get commission-address)))
                ;; total of 5% = u500
                (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
                (ok true)
        )
        (ok true)
    )
)

(define-public (set-commission (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get commission-address)) ERR-NOT-AUTHORIZED)
        (var-set commission amount)
        (ok true)
    )
)

(define-public (set-commission-address (address principal))
    (begin
        (asserts! (is-eq tx-sender (var-get commission-address)) ERR-NOT-AUTHORIZED)
        ;; (var-set commission-address address)
        (ok (var-get commission-address))
    )
)

(define-public (get-commission)
    (ok (var-get commission))
)

(define-public (get-commission-address)
    (ok (var-get commission-address))
)