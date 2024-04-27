(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant amount-btc (*  u16125 ONE_8))
(define-constant amount-alex (* u35475 ONE_8
))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wbtc-50-50-v1-01 amount-btc amount-btc amount-btc amount-btc amount-btc))
		(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-alex-50-50-v1-01 amount-alex amount-alex amount-alex amount-alex amount-alex))
		(ok true)	
	)
)