;; NOT A PRODUCTION DEPLOYMENT
;; This contract should be used for test purposes only

(define-constant ERR_NOT_AUTHORIZED (err u1001))

(define-constant CONTRACT_OWNER tx-sender)

(define-public (swap-a (amount uint))
  (let (
    (sender tx-sender)
    (a (unwrap-panic (stsw-a amount)))
    (b (unwrap-panic (usm-a a)))
    (c (unwrap-panic (alex-a b)))
  )
    (print {a: a, b: b, c: c})
    (begin
      (asserts! (is-eq sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
      (asserts! (> c amount) (err u1234567890))
    )
    (ok (list amount a b c))
  )
)

(define-public (stsw-a (dx uint))
  (let (
    (call (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.uwu-token-v1-1-0 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kglq1fqfp dx u100)))
  )
    (ok (unwrap-panic (element-at call u1)))
  )
)

(define-public (usm-a (dx uint))
  (let (
    (call (try! (contract-call? 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.uwu-stability-module-v1-1-0 swap-x-for-y dx)))
  )
    (ok (* (- dx (/ (* dx u50) u10000)) u100))
  )
)

(define-public (alex-a (dx uint))
  (let (
    (call (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u100))))
  )
    (ok call)
  )
)