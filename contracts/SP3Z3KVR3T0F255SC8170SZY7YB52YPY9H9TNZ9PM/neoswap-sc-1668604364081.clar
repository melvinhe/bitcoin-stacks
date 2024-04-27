(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4)
(define-constant agent-2 'SP1MC208VW1JT6DQX9VVQPPCMKFDK9XBN48RTEAVD)
(define-constant agent-3 'SP1TTT801S70Q28W1W4MMC7B081G8K2ZNGRR2VPRS)
(define-constant agent-4 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V)
(define-constant agent-5 'SP2488T0YRBG9GDGKE4T8B30PD2DVHZRFCHM0HTWS)
(define-constant agent-6 'SP2B2GF8JD02GSFBQ9VRFC327HVR4PMHVFX108F3M)
(define-constant agent-7 'SP2EMNEM8RCSMGKKVRX82DEZ7S927S4RPW8ZSH0XG)
(define-constant agent-8 'SP2RQEWQYEADZ6RN621C3N08EM4C0YEABGR55KJBB)
(define-constant agent-9 'SP2RYE0SHRTZPZ530438VJF688YCJ98CAGWHQ2AK)
(define-constant agent-10 'SP39AKEQWB4BJKB7HT1CHZ1KCMQ597MJ0WKRNB3GA)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool true)
(define-data-var agent-4-status bool false)
(define-data-var agent-5-status bool true)
(define-data-var agent-6-status bool true)
(define-data-var agent-7-status bool true)
(define-data-var agent-8-status bool true)
(define-data-var agent-9-status bool true)
(define-data-var agent-10-status bool true)


(define-data-var flag bool false)

(define-data-var deal bool false)

(define-constant deal-closed (err u300))
(define-constant cannot-escrow-nft (err u301))
(define-constant cannot-escrow-stx (err u302))
(define-constant sender-already-confirmed (err u303))
(define-constant non-tradable-agent (err u304))
(define-constant release-escrow-failed (err u305))
(define-constant deal-cancelled (err u306))
(define-constant escrow-not-ready (err u307))


;; u501 - Progress ; u502 - Cancelled ; u503 - Finished ; u504 - Escrow Ready
(define-data-var contract-status uint u501)


(define-read-only (check-contract-status) (ok (var-get contract-status)))

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (as-contract (contract-call? 'SP140MXYA1DSF1R0VZ5YGGQ5XR9FT5H7YTX26N2B8.bitcoin-beagle transfer u14 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.bitcoin-army transfer u23 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u242 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacksdev-v2 transfer u10 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u869 tx-sender agent-8)))
	(unwrap-panic (as-contract (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.bitcoin-army transfer u25 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3100 tx-sender agent-10)))

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacksdev-v2 transfer u10 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u869 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3100 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP140MXYA1DSF1R0VZ5YGGQ5XR9FT5H7YTX26N2B8.bitcoin-beagle transfer u14 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u242 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.bitcoin-army transfer u25 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.bitcoin-army transfer u23 tx-sender agent-4)))
	(var-set agent-4-status false))
	true)

	(var-set contract-status u502)
	(ok true)
))

(define-public (confirm-and-escrow)
(begin
	(asserts! (not (is-eq (var-get contract-status) u503)) deal-closed)
	(asserts! (not (is-eq (var-get contract-status) u502)) deal-cancelled)
	(var-set flag false)
	(unwrap-panic (begin
		(if (is-eq tx-sender agent-1)
		(begin
		(asserts! (is-eq (var-get agent-1-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacksdev-v2 transfer u10 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u869 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3100 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP140MXYA1DSF1R0VZ5YGGQ5XR9FT5H7YTX26N2B8.bitcoin-beagle transfer u14 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u242 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.bitcoin-army transfer u25 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.bitcoin-army transfer u23 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-4-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10))
	(begin
	(unwrap-panic (cancel-escrow))
	(ok true))
	non-tradable-agent)
))

(define-public (complete-neoswap)
(begin
	(asserts! (not (is-eq (var-get contract-status) u501)) escrow-not-ready)
	(asserts! (not (is-eq (var-get contract-status) u503)) deal-closed)
	(asserts! (not (is-eq (var-get contract-status) u502)) deal-cancelled)
	(unwrap-panic (release-escrow))
	(ok true)
))
