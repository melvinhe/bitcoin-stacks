(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-vault add-approved-contract .amm-swap-pool))
		(try! (contract-call? .alex-reserve-pool add-approved-contract .amm-swap-pool))
		(try! (contract-call? .amm-swap-pool set-fee-rebate .token-wxusd .token-wusda u10000 u50000000))
		(try! (contract-call? .amm-swap-pool set-oracle-enabled .token-wxusd .token-wusda u10000 true))
		(try! (contract-call? .amm-swap-pool set-oracle-average .token-wxusd .token-wusda u10000 u99000000))
		(try! (contract-call? .amm-swap-pool set-threshold-x .token-wxusd .token-wusda u10000 u1000000000))
		(try! (contract-call? .amm-swap-pool set-threshold-y .token-wxusd .token-wusda u10000 u1000000000))
		(ok true)
	)
)