(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2597NW8VYYVV4C22WQF3DK0WGQS8TAVDDPXQ5H8))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP1GPNZB0JSC9RXJTXVBAMSPQE29WM1SE8V39R6K2))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX))
        (ok true)))
