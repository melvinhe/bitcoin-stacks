(define-public (register (x uint)) (ok (match (contract-call? 'SP2TXH2T3JB6AJ8EFBK59TP69PH5Q3VD9A453M2NQ.amm-swap-pool-v1-1 swap-helper-a x) r (ok r) r (err r))))