(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP1EZ5KSEECD88K26499PD4PPAJEFZ7CW0J1EBMQP)
(define-constant agent-2 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9)
(define-constant agent-3 'SP1N41GX5EVPR9SD7JM8T1165YP5G279JE9V9XFH0)
(define-constant agent-4 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant agent-5 'SP2CHJ9TQ827NKFFHJ5JR4TYNM6WA6N8D17J49XX1)
(define-constant agent-6 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD)
(define-constant agent-7 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE)
(define-constant agent-0 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)
(define-data-var agent-4-status bool false)
(define-data-var agent-5-status bool false)
(define-data-var agent-6-status bool false)
(define-data-var agent-7-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1000000 tx-sender agent-1)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u285 tx-sender agent-2)))
		(as-contract (stx-transfer? u15980000 tx-sender agent-2)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1500000 tx-sender agent-3)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u104 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u79 tx-sender agent-4)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u250000 tx-sender agent-5)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1693 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3270 tx-sender agent-7)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u940000 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u79 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1693 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u104 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3270 tx-sender agent-3)))
	(var-set agent-3-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u2000000 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u285 tx-sender agent-5)))
	(var-set agent-5-status false))
	true)
	(if (is-eq (var-get agent-6-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u17040000 tx-sender agent-6)))
	)
	(var-set agent-6-status false)
	)
	true
	)
	(if (is-eq (var-get agent-7-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u630000 tx-sender agent-7)))
	)
	(var-set agent-7-status false)
	)
	true
	)

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
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u79 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1693 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u104 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3270 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u2000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u285 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u17040000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u630000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-7-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7))
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
