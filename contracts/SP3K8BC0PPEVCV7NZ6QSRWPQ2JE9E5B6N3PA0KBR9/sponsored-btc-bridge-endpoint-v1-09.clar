(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-not-authorized (err u1000))
(define-data-var contract-owner principal tx-sender)
(define-data-var sponsored-fee uint u0)
(define-read-only (get-sponsored-fee)
    (var-get sponsored-fee)
)
(define-public (set-sponsored-fee (fee uint))
    (begin 
        (try! (check-is-owner))
        (ok (var-set sponsored-fee fee))))
(define-public (request-peg-out-0 (peg-out-address (buff 128)) (amount uint))
    (begin
        (try! (pay-to-sponsor))
        (contract-call? .btc-bridge-endpoint-v1-09 request-peg-out-0 peg-out-address amount)))
(define-public (request-peg-out-1 (peg-out-address (buff 128)) (token-trait <sip010-trait>) (factor uint) (dx uint) (min-dy (optional uint)))
    (begin
        (try! (pay-to-sponsor))
        (contract-call? .btc-bridge-endpoint-v1-09 request-peg-out-1 peg-out-address token-trait factor dx min-dy)))
(define-public (request-peg-out-2 (peg-out-address (buff 128)) (token1-trait <sip010-trait>) (token2-trait <sip010-trait>) (factor1 uint) (factor2 uint) (dx uint) (min-dz (optional uint)))
    (begin
        (try! (pay-to-sponsor))
        (contract-call? .btc-bridge-endpoint-v1-09 request-peg-out-2 peg-out-address token1-trait token2-trait factor1 factor2 dx min-dz)))
(define-public (request-peg-out-3 (peg-out-address (buff 128)) (token1-trait <sip010-trait>) (token2-trait <sip010-trait>) (token3-trait <sip010-trait>) (factor1 uint) (factor2 uint) (factor3 uint) (dx uint) (min-dw (optional uint)))
    (begin
        (try! (pay-to-sponsor))
        (contract-call? .btc-bridge-endpoint-v1-09 request-peg-out-3 peg-out-address token1-trait token2-trait token3-trait factor1 factor2 factor3 dx min-dw)))
(define-public (revoke-peg-out (request-id uint))
    (begin
        (try! (pay-to-sponsor))
        (contract-call? .btc-bridge-endpoint-v1-09 revoke-peg-out request-id)))
(define-private (check-is-owner)
	(ok (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized))
)
(define-private (pay-to-sponsor)
    (match tx-sponsor? sponsor (contract-call? .token-abtc transfer-fixed (var-get sponsored-fee) tx-sender sponsor none) (ok false))
)