(define-public (update-price-multi (x uint)) (ok (match (contract-call? 'SP2TXH2T3JB6AJ8EFBK59TP69PH5Q3VD9A453M2NQ.staking-helper claim-staking-reward x) r (ok r) r (err r))))