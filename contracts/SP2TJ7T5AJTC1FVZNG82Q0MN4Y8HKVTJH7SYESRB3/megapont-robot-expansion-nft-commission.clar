(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u0)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
            (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX))
            (ok true)
        )
        (ok true)
    )
)
