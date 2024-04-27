(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-peg-in-address-not-found (err u1002))
(define-constant err-invalid-amount (err u1003))
(define-constant err-invalid-tx (err u1004))
(define-constant err-already-sent (err u1005))
(define-constant err-address-mismatch (err u1006))
(define-constant err-request-already-revoked (err u1007))
(define-constant err-request-already-finalized (err u1008))
(define-constant err-revoke-grace-period (err u1009))
(define-constant err-request-already-claimed (err u1010))
(define-constant err-bitcoin-tx-not-mined (err u1011))
(define-constant err-invalid-input (err u1012))
(define-constant err-tx-mined-before-request (err u1013))
(define-constant err-dest-mismatch (err u1014))
(define-constant err-token-mismatch (err u1015))
(define-constant err-slippage (err u1016))
(define-constant err-not-in-whitelist (err u1017))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-data-var contract-owner principal tx-sender)
(define-data-var fee-address principal tx-sender)
(define-data-var peg-in-paused bool true)
(define-data-var peg-out-paused bool true)
(define-data-var peg-in-fee uint u0)
(define-data-var peg-in-min-fee uint u0)
(define-data-var peg-out-fee uint u0)
(define-data-var peg-out-min-fee uint u0)
(define-map use-whitelist uint bool)
(define-map whitelisted {launch-id: uint, owner: (buff 128)} bool)
(define-public (set-use-whitelist (launch-id uint) (new-whitelisted bool))
	(begin 
		(try! (is-contract-owner))
		(ok (map-set use-whitelist launch-id new-whitelisted))))
(define-public (set-whitelisted (launch-id uint) (whitelisted-users (list 200 {owner: (buff 128), whitelisted: bool})))
	(begin
		(try! (is-contract-owner))
		(fold set-whitelisted-iter whitelisted-users launch-id)
		(ok true)))
(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set contract-owner new-contract-owner))))
(define-public (set-fee-address (new-fee-address principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set fee-address new-fee-address))))
(define-public (pause-peg-in (paused bool))
	(begin
		(try! (is-contract-owner))
		(ok (var-set peg-in-paused paused))))
(define-public (pause-peg-out (paused bool))
	(begin
		(try! (is-contract-owner))
		(ok (var-set peg-out-paused paused))))
(define-public (set-peg-in-fee (fee uint))
	(begin
		(try! (is-contract-owner))
		(ok (var-set peg-in-fee fee))))
(define-public (set-peg-in-min-fee (fee uint))
	(begin
		(try! (is-contract-owner))
		(ok (var-set peg-in-min-fee fee))))
(define-public (set-peg-out-fee (fee uint))
	(begin
		(try! (is-contract-owner))
		(ok (var-set peg-out-fee fee))))
(define-public (set-peg-out-min-fee (fee uint))
	(begin
		(try! (is-contract-owner))
		(ok (var-set peg-out-min-fee fee))))
(define-read-only (is-peg-in-paused)
	(var-get peg-in-paused))
(define-read-only (is-peg-out-paused)
	(var-get peg-out-paused))
(define-read-only (get-peg-in-fee)
	(var-get peg-in-fee))
(define-read-only (get-peg-in-min-fee)
	(var-get peg-in-min-fee))
(define-read-only (get-peg-out-fee)
	(var-get peg-out-fee))
(define-read-only (get-peg-out-min-fee)
	(var-get peg-out-min-fee))
(define-read-only (get-request-revoke-grace-period)
	(contract-call? .btc-bridge-registry-v1-01 get-request-revoke-grace-period))
(define-read-only (get-request-claim-grace-period)
	(contract-call? .btc-bridge-registry-v1-01 get-request-claim-grace-period))
(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(contract-call? .btc-bridge-registry-v1-01 is-peg-in-address-approved address))
(define-read-only (get-request-or-fail (request-id uint))
	(contract-call? .btc-bridge-registry-v1-01 get-request-or-fail request-id))
(define-read-only (get-peg-in-sent-or-default (tx (buff 4096)) (output uint))
	(contract-call? .btc-bridge-registry-v1-01 get-peg-in-sent-or-default tx output))
(define-read-only (get-fee-address)
	(var-get fee-address))
(define-read-only (extract-tx-ins-outs (tx (buff 4096)))
	(if (try! (contract-call? .clarity-bitcoin-v1-03 is-segwit-tx tx))
		(let (
				(parsed-tx (unwrap! (contract-call? .clarity-bitcoin-v1-03 parse-wtx tx) err-invalid-tx)))
			(ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) }))
		(let (
				(parsed-tx (unwrap! (contract-call? .clarity-bitcoin-v1-03 parse-tx tx) err-invalid-tx)))
			(ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) }))
	))
(define-read-only (get-txid (tx (buff 4096)))
	(if (try! (contract-call? .clarity-bitcoin-v1-03 is-segwit-tx tx))
		(ok (contract-call? .clarity-bitcoin-v1-03 get-segwit-txid tx))
		(ok (contract-call? .clarity-bitcoin-v1-03 get-txid tx))
	))
(define-read-only (get-use-whitelist-or-default (launch-id uint))
	(default-to false (map-get? use-whitelist launch-id)))
(define-read-only (get-whitelisted-or-default (launch-id uint) (owner (buff 128)))
	(if (get-use-whitelist-or-default launch-id)
		(default-to false (map-get? whitelisted {launch-id: launch-id, owner: owner}))
		true))
(define-read-only (verify-mined (tx (buff 4096)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(if (is-eq chain-id u1)
		(let (
				(response (if (try! (contract-call? .clarity-bitcoin-v1-03 is-segwit-tx tx))
					(contract-call? .clarity-bitcoin-v1-03 was-segwit-tx-mined? block tx proof)
					(contract-call? .clarity-bitcoin-v1-03 was-tx-mined? block tx proof))
				))
			(if (or (is-err response) (not (unwrap-panic response)))
				err-bitcoin-tx-not-mined
				(ok true)
			))
		(ok true))) ;; if not mainnet, assume verified
(define-read-only (create-order-0-or-fail (order principal))
	(ok (unwrap! (to-consensus-buff? order) err-invalid-input)))
(define-read-only (decode-order-0-or-fail (order-script (buff 128)))
	(let (
			(op-code (unwrap-panic (slice? order-script u1 u2))))
			(ok (unwrap! (from-consensus-buff? principal (unwrap-panic (slice? order-script (if (< op-code 0x4c) u2 u3) (len order-script)))) err-invalid-input))))
(define-read-only (validate-tx-0 (tx (buff 4096)) (output-idx uint) (order-idx uint))
	(let (
		(validation-data (try! (validate-tx-common tx output-idx order-idx))))
		(ok { order-details: (try! (decode-order-0-or-fail (get order-script validation-data))), fee: (get fee validation-data), amount-net: (get amount-net validation-data) })))
(define-read-only (create-order-1-or-fail (order { user: principal, pool-id: uint, min-dy: uint }))
	(ok (unwrap! (to-consensus-buff? { u: (get user order), p: (int-to-ascii (get pool-id order)), y: (int-to-ascii (get min-dy order)) }) err-invalid-input)))
(define-read-only (decode-order-1-or-fail (order-script (buff 128)))
	(let (
			(op-code (unwrap-panic (slice? order-script u1 u2)))
			(offset (if (< op-code 0x4c) u2 u3))
			(raw-order (unwrap! (from-consensus-buff? { u: principal, p: (string-ascii 40), y: (string-ascii 40) } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input))
			(pool-id (unwrap! (string-to-uint? (get p raw-order)) err-invalid-input))
			(min-dy (unwrap! (string-to-uint? (get y raw-order)) err-invalid-input)))
		(ok { user: (get u raw-order), pool-id: pool-id, min-dy: min-dy })))
(define-read-only (validate-tx-1 (tx (buff 4096)) (output-idx uint) (order-idx uint) (token principal))
	(validate-tx-1-extra (try! (validate-tx-1-base tx output-idx order-idx)) token))
(define-read-only (create-order-2-or-fail (order { user: principal, pool1-id: uint, pool2-id: uint, min-dz: uint }))
	(ok (unwrap! (to-consensus-buff? { u: (get user order), p1: (int-to-ascii (get pool1-id order)), p2: (int-to-ascii (get pool2-id order)), z: (int-to-ascii (get min-dz order)) }) err-invalid-input)))
(define-read-only (decode-order-2-or-fail (order-script (buff 128)))
	(let (
			(op-code (unwrap-panic (slice? order-script u1 u2)))
			(offset (if (< op-code 0x4c) u2 u3))
			(raw-order (unwrap! (from-consensus-buff? { u: principal, p1: (string-ascii 40), p2: (string-ascii 40), z: (string-ascii 40) } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input))
			(pool1-id (unwrap! (string-to-uint? (get p1 raw-order)) err-invalid-input))
			(pool2-id (unwrap! (string-to-uint? (get p2 raw-order)) err-invalid-input))
			(min-dz (unwrap! (string-to-uint? (get z raw-order)) err-invalid-input)))
		(ok { user: (get u raw-order), pool1-id: pool1-id, pool2-id: pool2-id, min-dz: min-dz })))
(define-read-only (validate-tx-2 (tx (buff 4096)) (output-idx uint) (order-idx uint) (token1 principal) (token2 principal))
	(validate-tx-2-extra (try! (validate-tx-2-base tx output-idx order-idx)) token1 token2))
(define-read-only (create-order-3-or-fail (order { user: principal, pool1-id: uint, pool2-id: uint, pool3-id: uint, min-dw: uint }))
	(ok (unwrap! (to-consensus-buff? { u: (get user order), p1: (int-to-ascii (get pool1-id order)), p2: (int-to-ascii (get pool2-id order)), p3: (int-to-ascii (get pool3-id order)), w: (int-to-ascii (get min-dw order)) }) err-invalid-input)))
(define-read-only (decode-order-3-or-fail (order-script (buff 128)))
	(let (
			(op-code (unwrap-panic (slice? order-script u1 u2)))
			(offset (if (< op-code 0x4c) u2 u3))
			(raw-order (unwrap! (from-consensus-buff? { u: principal, p1: (string-ascii 40), p2: (string-ascii 40), p3: (string-ascii 40), w: (string-ascii 40) } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input))
			(pool1-id (unwrap! (string-to-uint? (get p1 raw-order)) err-invalid-input))
			(pool2-id (unwrap! (string-to-uint? (get p2 raw-order)) err-invalid-input))
			(pool3-id (unwrap! (string-to-uint? (get p3 raw-order)) err-invalid-input))
			(min-dw (unwrap! (string-to-uint? (get w raw-order)) err-invalid-input)))
		(ok { user: (get u raw-order), pool1-id: pool1-id, pool2-id: pool2-id, pool3-id: pool3-id, min-dw: min-dw })))
(define-read-only (validate-tx-3 (tx (buff 4096)) (output-idx uint) (order-idx uint) (token1 principal) (token2 principal) (token3 principal))
	(validate-tx-3-extra (try! (validate-tx-3-base tx output-idx order-idx)) token1 token2 token3))
(define-read-only (create-order-launchpad-or-fail (order { user: principal, launch-id: uint }))
	(ok (unwrap! (to-consensus-buff? { u: (get user order), l: (int-to-ascii (get launch-id order)) }) err-invalid-input)))
(define-read-only (decode-order-launchpad-or-fail (order-script (buff 128)))
	(let (
			(op-code (unwrap-panic (slice? order-script u1 u2)))
			(offset (if (< op-code 0x4c) u2 u3))
			(raw-order (unwrap! (from-consensus-buff? { u: principal, l: (string-ascii 40) } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input))
			(launch-id (unwrap! (string-to-uint? (get l raw-order)) err-invalid-input)))
		(ok { user: (get u raw-order), launch-id: launch-id })))
(define-read-only (validate-tx-launchpad (tx (buff 4096)) (output-idx uint) (order-idx uint) (owner-idx uint))
	(validate-tx-launchpad-extra (try! (validate-tx-launchpad-base tx output-idx order-idx owner-idx))))
(define-public (finalize-peg-in-0
	(tx (buff 4096))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (order-idx uint))
	(let (
			(common-check (try! (finalize-peg-in-common tx block proof output-idx order-idx)))
			(validation-data (try! (validate-tx-0 tx output-idx order-idx)))
			(order-details (get order-details validation-data))
			(amount-net (get amount-net validation-data))
			(fee (get fee validation-data)))
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-peg-in-sent tx output-idx true)))
		(and (> fee u0) (as-contract (try! (contract-call? .token-abtc mint-fixed fee (var-get fee-address)))))
		(as-contract (try! (contract-call? .token-abtc mint-fixed amount-net order-details)))
		(print { type: "peg-in", tx-id: (try! (get-txid tx)), output: output-idx, order-details: order-details, fee: fee, amount-net: amount-net })
		(ok true)))
(define-public (finalize-peg-in-1
	(tx (buff 4096))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (order-idx uint)
	(token-trait <sip010-trait>))
	(let (
			(common-check (try! (finalize-peg-in-common tx block proof output-idx order-idx)))
			(validation-data (try! (validate-tx-1-base tx output-idx order-idx)))
			(order-details (get order-details validation-data))
			(amount-net (get amount-net validation-data))
			(fee (get fee validation-data))
			(minted (as-contract (try! (contract-call? .token-abtc mint-fixed amount-net tx-sender)))))
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-peg-in-sent tx output-idx true)))
		(and (> fee u0) (as-contract (try! (contract-call? .token-abtc mint-fixed fee (var-get fee-address)))))
		(print { type: "peg-in", tx-id: (try! (get-txid tx)), output: output-idx, order-details: order-details, fee: fee, amount-net: amount-net })
		(match (validate-tx-1-extra validation-data (contract-of token-trait))
			extra-details
			(let (
					(swapped (as-contract (try! (contract-call? .amm-swap-pool-v1-1 swap-helper .token-abtc token-trait (get factor extra-details) amount-net (some (get min-dy order-details)))))))
				(as-contract (try! (contract-call? token-trait transfer-fixed swapped	tx-sender (get user order-details) none)))
				(ok true)
			)
			err-value
			(begin
				(as-contract (try! (contract-call? .token-abtc transfer-fixed amount-net tx-sender (get user order-details) none)))
				(ok false)
			)
		)))
(define-public (finalize-peg-in-2
	(tx (buff 4096))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (order-idx uint)
	(token1-trait <sip010-trait>) (token2-trait <sip010-trait>))
	(let (
			(common-check (try! (finalize-peg-in-common tx block proof output-idx order-idx)))
			(validation-data (try! (validate-tx-2-base tx output-idx order-idx)))
			(order-details (get order-details validation-data))
			(amount-net (get amount-net validation-data))
			(fee (get fee validation-data))
			(minted (as-contract (try! (contract-call? .token-abtc mint-fixed amount-net tx-sender)))))
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-peg-in-sent tx output-idx true)))
		(and (> fee u0) (as-contract (try! (contract-call? .token-abtc mint-fixed fee (var-get fee-address)))))
		(print { type: "peg-in", tx-id: (try! (get-txid tx)), output: output-idx, order-details: order-details, fee: fee, amount-net: amount-net })
		(match (validate-tx-2-extra validation-data (contract-of token1-trait) (contract-of token2-trait))
			extra-details
			(let (
					(swapped (as-contract (try! (contract-call? .amm-swap-pool-v1-1 swap-helper-a .token-abtc token1-trait token2-trait (get factor1 extra-details) (get factor2 extra-details) amount-net (some (get min-dz order-details)))))))
				(as-contract (try! (contract-call? token2-trait transfer-fixed swapped tx-sender (get user order-details) none)))
				(ok true)
			)
			err-value
			(begin
				(as-contract (try! (contract-call? .token-abtc transfer-fixed amount-net tx-sender (get user order-details) none)))
				(ok false)
			)
		)))
(define-public (finalize-peg-in-3
	(tx (buff 4096))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (order-idx uint)
	(token1-trait <sip010-trait>) (token2-trait <sip010-trait>) (token3-trait <sip010-trait>))
	(let (
			(common-check (try! (finalize-peg-in-common tx block proof output-idx order-idx)))
			(validation-data (try! (validate-tx-3-base tx output-idx order-idx)))
			(order-details (get order-details validation-data))
			(amount-net (get amount-net validation-data))
			(fee (get fee validation-data))
			(minted (as-contract (try! (contract-call? .token-abtc mint-fixed amount-net tx-sender)))))
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-peg-in-sent tx output-idx true)))
		(and (> fee u0) (as-contract (try! (contract-call? .token-abtc mint-fixed fee (var-get fee-address)))))
		(print { type: "peg-in", tx-id: (try! (get-txid tx)), output: output-idx, order-details: order-details, fee: fee, amount-net: amount-net })
		(match (validate-tx-3-extra validation-data (contract-of token1-trait) (contract-of token2-trait) (contract-of token3-trait))
			extra-details
			(let (
					(swapped (as-contract (try! (contract-call? .amm-swap-pool-v1-1 swap-helper-b .token-abtc token1-trait token2-trait token3-trait (get factor1 extra-details) (get factor2 extra-details) (get factor3 extra-details) amount-net (some (get min-dw order-details)))))))
				(as-contract (try! (contract-call? token3-trait transfer-fixed swapped tx-sender (get user order-details) none)))
				(ok true)
			)
			err-value
			(begin
				(as-contract (try! (contract-call? .token-abtc transfer-fixed amount-net tx-sender (get user order-details) none)))
				(ok false)
			)
		)))
(define-public (finalize-peg-in-launchpad
	(tx (buff 4096))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (order-idx uint) (owner-idx uint))
	(let (
			(common-check (try! (finalize-peg-in-common tx block proof output-idx order-idx)))
			(validation-data (try! (validate-tx-launchpad-base tx output-idx order-idx owner-idx)))
			(order-details (get order-details validation-data))
			(amount-net (get amount-net validation-data))
			(fee (get fee validation-data)))
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-peg-in-sent tx output-idx true)))
		(and (> fee u0) (as-contract (try! (contract-call? .token-abtc mint-fixed fee (var-get fee-address)))))
		(as-contract (try! (contract-call? .token-abtc mint-fixed amount-net tx-sender)))
		(print { type: "peg-in", tx-id: (try! (get-txid tx)), output: output-idx, order-details: order-details, fee: fee, amount-net: amount-net })
		(if (is-ok (validate-tx-launchpad-extra validation-data))
			(let (
				(bounds (as-contract (try! (contract-call? .alex-launchpad-v1-5 register-on-behalf (get user order-details) (get launch-id order-details) amount-net .token-abtc)))))
				(map-set whitelisted { launch-id: (get launch-id order-details), owner: (get owner-script validation-data) } false)
				(ok bounds)
			)
			(begin
				(as-contract (try! (contract-call? .token-abtc transfer-fixed amount-net tx-sender (get user order-details) none)))
				(ok { start: u0, end: u0 })
			)
		)))
(define-public (request-peg-out-0 (peg-out-address (buff 128)) (amount uint))
	(let (
			(gas-fee (var-get peg-out-min-fee))
			(fee (- (max (mul-down amount (var-get peg-out-fee)) gas-fee) gas-fee))
			(check-amount (asserts! (> amount (+ fee gas-fee)) err-invalid-amount))
			(amount-net (- amount fee gas-fee))			
			(request-details { requested-by: tx-sender, peg-out-address: peg-out-address, amount-net: amount-net, fee: fee, gas-fee: gas-fee, claimed: u0, claimed-by: tx-sender, fulfilled-by: 0x, revoked: false, finalized: false, requested-at: block-height, requested-at-burn-height: burn-block-height })
			(request-id (as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-request u0 request-details)))))
		(asserts! (not (var-get peg-out-paused)) err-paused)
		(try! (contract-call? .token-abtc transfer-fixed amount tx-sender (as-contract tx-sender) none))
		(print (merge request-details { type: "request-peg-out", request-id: request-id }))
		(ok request-id)))
(define-public (request-peg-out-1 (peg-out-address (buff 128)) (token-trait <sip010-trait>) (factor uint) (dx uint) (min-dy (optional uint)))
	(let (
			(swapped (try! (contract-call? .amm-swap-pool-v1-1 swap-helper token-trait .token-abtc factor dx min-dy))))
		(request-peg-out-0 peg-out-address swapped)))
(define-public (request-peg-out-2 (peg-out-address (buff 128)) (token1-trait <sip010-trait>) (token2-trait <sip010-trait>) (factor1 uint) (factor2 uint) (dx uint) (min-dz (optional uint)))
	(let (
			(swapped (try! (contract-call? .amm-swap-pool-v1-1 swap-helper-a token1-trait token2-trait .token-abtc factor1 factor2 dx min-dz))))
		(request-peg-out-0 peg-out-address swapped)))
(define-public (request-peg-out-3 (peg-out-address (buff 128)) (token1-trait <sip010-trait>) (token2-trait <sip010-trait>) (token3-trait <sip010-trait>) (factor1 uint) (factor2 uint) (factor3 uint) (dx uint) (min-dw (optional uint)))
	(let (
			(swapped (try! (contract-call? .amm-swap-pool-v1-1 swap-helper-b token1-trait token2-trait token3-trait .token-abtc factor1 factor2 factor3 dx min-dw))))
		(request-peg-out-0 peg-out-address swapped)))
(define-public (claim-peg-out (request-id uint) (fulfilled-by (buff 128)))
	(let (
			(claimer tx-sender)
			(request-details (try! (get-request-or-fail request-id))))
		(asserts! (not (var-get peg-out-paused)) err-paused)
		(asserts! (< (get claimed request-details) block-height) err-request-already-claimed)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-request request-id (merge request-details { claimed: (+ block-height (get-request-claim-grace-period)), claimed-by: claimer, fulfilled-by: fulfilled-by }))))
		(print (merge request-details { type: "claim-peg-out", request-id: request-id, claimed: (+ block-height (get-request-claim-grace-period)), claimed-by: claimer, fulfilled-by: fulfilled-by }))
		(ok true)
	)
)
(define-public (finalize-peg-out
	(request-id uint)
	(tx (buff 4096))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (fulfilled-by-idx uint))
	(let (
			(request-details (try! (get-request-or-fail request-id)))
			(was-mined (try! (verify-mined tx block proof)))
			(parsed-tx (try! (extract-tx-ins-outs tx)))
			(output (unwrap! (element-at (get outs parsed-tx) output-idx) err-invalid-tx))
			(fulfilled-by (get scriptPubKey (unwrap! (element-at (get outs parsed-tx) fulfilled-by-idx) err-invalid-tx)))
			(amount (get value output))
			(peg-out-address (get scriptPubKey output))
			(is-fulfilled-by-peg-in (is-peg-in-address-approved fulfilled-by))
			)
		(asserts! (not (var-get peg-out-paused)) err-paused)
		(asserts! (is-eq amount (get amount-net request-details)) err-invalid-amount)
		(asserts! (is-eq (get peg-out-address request-details) peg-out-address) err-address-mismatch)
		(asserts! (is-eq (get fulfilled-by request-details) fulfilled-by) err-address-mismatch)
		(asserts! (< (get requested-at-burn-height request-details) (get height block)) err-tx-mined-before-request)
		;; (asserts! (<= block-height (get claimed request-details)) err-request-claim-expired) ;; allow fulfilled if not claimed again
		(asserts! (not (get-peg-in-sent-or-default tx output-idx)) err-already-sent)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-peg-in-sent tx output-idx true)))
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-request request-id (merge request-details { finalized: true }))))
		(and (> (get fee request-details) u0) (as-contract (try! (contract-call? .token-abtc transfer-fixed (get fee request-details) tx-sender (var-get fee-address) none))))
		(and (> (get gas-fee request-details) u0) (as-contract (try! (contract-call? .token-abtc transfer-fixed (get gas-fee request-details) tx-sender (if is-fulfilled-by-peg-in (var-get fee-address) (get claimed-by request-details)) none))))
		(if is-fulfilled-by-peg-in
			(as-contract (try! (contract-call? .token-abtc burn-fixed (get amount-net request-details) tx-sender)))
			(as-contract (try! (contract-call? .token-abtc transfer-fixed (get amount-net request-details) tx-sender (get claimed-by request-details) none)))
		)
		(print { type: "finalize-peg-out", request-id: request-id, tx: tx })
		(ok true)))
(define-public (revoke-peg-out (request-id uint))
	(let (
			(request-details (try! (get-request-or-fail request-id))))
		(asserts! (> block-height (+ (get requested-at request-details) (get-request-revoke-grace-period))) err-revoke-grace-period)
		(asserts! (< (get claimed request-details) block-height) err-request-already-claimed)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)
		(as-contract (try! (contract-call? .btc-bridge-registry-v1-01 set-request request-id (merge request-details { revoked: true }))))
		(and (> (get fee request-details) u0) (as-contract (try! (contract-call? .token-abtc transfer-fixed (get fee request-details) tx-sender (get requested-by request-details) none))))
		(and (> (get gas-fee request-details) u0) (as-contract (try! (contract-call? .token-abtc transfer-fixed (get gas-fee request-details) tx-sender (get requested-by request-details) none))))
		(as-contract (try! (contract-call? .token-abtc transfer-fixed (get amount-net request-details) tx-sender (get requested-by request-details) none)))
		(print { type: "revoke-peg-out", request-id: request-id })
		(ok true)))
(define-private (validate-tx-1-base (tx (buff 4096)) (output-idx uint) (order-idx uint))
	(let (
			(validation-data (try! (validate-tx-common tx output-idx order-idx))))
		(ok { order-details: (try! (decode-order-1-or-fail (get order-script validation-data))), fee: (get fee validation-data), amount-net: (get amount-net validation-data) })))
(define-private (validate-tx-1-extra (validation-data { order-details: { user: principal, pool-id: uint, min-dy: uint }, fee: uint, amount-net: uint }) (token principal))
	(let (
			(order-details (get order-details validation-data))
			(pool-details (try! (contract-call? .amm-swap-pool-v1-1 get-pool-details-by-id (get pool-id order-details))))
			(token-y (if (is-eq (get token-x pool-details) .token-abtc) (get token-y pool-details) (get token-x pool-details)))
			(factor (get factor pool-details))
			(dy (try! (contract-call? .amm-swap-pool-v1-1 get-helper .token-abtc token-y factor (get amount-net validation-data)))))
		(asserts! (>= dy (get min-dy order-details)) err-slippage)
		(asserts! (is-eq token-y token) err-token-mismatch)
		(ok { validation-data: validation-data, token-y: token-y, factor: factor })))
(define-private (validate-tx-2-base (tx (buff 4096)) (output-idx uint) (order-idx uint))
	(let (
			(validation-data (try! (validate-tx-common tx output-idx order-idx))))
		(ok { order-details: (try! (decode-order-2-or-fail (get order-script validation-data))), fee: (get fee validation-data), amount-net: (get amount-net validation-data) })))
(define-private (validate-tx-2-extra (validation-data { order-details: { user: principal, pool1-id: uint, pool2-id: uint, min-dz: uint }, fee: uint, amount-net: uint }) (token1 principal) (token2 principal))
	(let (
			(order-details (get order-details validation-data))
			(pool1-details (try! (contract-call? .amm-swap-pool-v1-1 get-pool-details-by-id (get pool1-id order-details))))
			(pool2-details (try! (contract-call? .amm-swap-pool-v1-1 get-pool-details-by-id (get pool2-id order-details))))
			(token1-y (if (is-eq (get token-x pool1-details) .token-abtc) (get token-y pool1-details) (get token-x pool1-details)))
			(token2-y (if (is-eq (get token-x pool2-details) token1-y) (get token-y pool2-details) (get token-x pool2-details)))
			(factor1 (get factor pool1-details))
			(factor2 (get factor pool2-details))
			(dz (try! (contract-call? .amm-swap-pool-v1-1 get-helper-a .token-abtc token1-y token2-y factor1 factor2 (get amount-net validation-data)))))
		(asserts! (is-eq token1-y token1) err-token-mismatch)
		(asserts! (is-eq token2-y token2) err-token-mismatch)
		(asserts! (>= dz (get min-dz order-details)) err-slippage)
		(ok { validation-data: validation-data, token1-y: token1-y, token2-y: token2-y, factor1: factor1, factor2: factor2 })))
(define-private (validate-tx-3-base (tx (buff 4096)) (output-idx uint) (order-idx uint))
	(let (
			(validation-data (try! (validate-tx-common tx output-idx order-idx))))
		(ok { order-details: (try! (decode-order-3-or-fail (get order-script validation-data))), fee: (get fee validation-data), amount-net: (get amount-net validation-data) })))
(define-private (validate-tx-3-extra (validation-data { order-details: { user: principal, pool1-id: uint, pool2-id: uint, pool3-id: uint, min-dw: uint }, fee: uint, amount-net: uint }) (token1 principal) (token2 principal) (token3 principal))
	(let (
			(order-details (get order-details validation-data))
			(pool1-details (try! (contract-call? .amm-swap-pool-v1-1 get-pool-details-by-id (get pool1-id order-details))))
			(pool2-details (try! (contract-call? .amm-swap-pool-v1-1 get-pool-details-by-id (get pool2-id order-details))))
			(pool3-details (try! (contract-call? .amm-swap-pool-v1-1 get-pool-details-by-id (get pool3-id order-details))))
			(token1-y (if (is-eq (get token-x pool1-details) .token-abtc) (get token-y pool1-details) (get token-x pool1-details)))
			(token2-y (if (is-eq (get token-x pool2-details) token1-y) (get token-y pool2-details) (get token-x pool2-details)))
			(token3-y (if (is-eq (get token-x pool3-details) token2-y) (get token-y pool3-details) (get token-x pool3-details)))
			(factor1 (get factor pool1-details))
			(factor2 (get factor pool2-details))
			(factor3 (get factor pool3-details))
			(dw (try! (contract-call? .amm-swap-pool-v1-1 get-helper-b .token-abtc token1-y token2-y token3-y factor1 factor2 factor3 (get amount-net validation-data)))))
		(asserts! (is-eq token1-y token1) err-token-mismatch)
		(asserts! (is-eq token2-y token2) err-token-mismatch)
		(asserts! (is-eq token3-y token3) err-token-mismatch)
		(asserts! (>= dw (get min-dw order-details)) err-slippage)
		(ok { validation-data: validation-data, token1-y: token1-y, token2-y: token2-y, token3-y: token3-y, factor1: factor1, factor2: factor2, factor3: factor3 })))
(define-private (validate-tx-launchpad-base (tx (buff 4096)) (output-idx uint) (order-idx uint) (owner-idx uint))
	(let (
			(validation-data (try! (validate-tx-common tx output-idx order-idx)))
			(owner-script (get scriptPubKey (unwrap-panic (element-at? (get outs (get parsed-tx validation-data)) owner-idx)))))
		(ok { owner-script: owner-script, order-details: (try! (decode-order-launchpad-or-fail (get order-script validation-data))), fee: (get fee validation-data), amount-net: (get amount-net validation-data) })))
(define-private (validate-tx-launchpad-extra (validation-data { owner-script: (buff 128), order-details: { user: principal, launch-id: uint }, fee: uint, amount-net: uint }))
	(let (
			(order-details (get order-details validation-data)))
		(asserts! (get-whitelisted-or-default (get launch-id order-details) (get owner-script validation-data)) err-not-in-whitelist)
		(try! (contract-call? .alex-launchpad-v1-5 validate-register (get user order-details) (get launch-id order-details) (get amount-net validation-data) .token-abtc))
		(ok validation-data)))
(define-private (validate-tx-common (tx (buff 4096)) (output-idx uint) (order-idx uint))
	(let (
			(parsed-tx (try! (extract-tx-ins-outs tx)))
			(output (unwrap! (element-at (get outs parsed-tx) output-idx) err-invalid-tx))
			(amount (get value output))
			(peg-in-address (get scriptPubKey output))
			(order-script (get scriptPubKey (unwrap-panic (element-at? (get outs parsed-tx) order-idx))))
			(fee (max (mul-down amount (var-get peg-in-fee)) (var-get peg-in-min-fee)))
			(amount-net (- amount fee)))
			(asserts! (not (get-peg-in-sent-or-default tx output-idx)) err-already-sent)
			(asserts! (is-peg-in-address-approved peg-in-address) err-peg-in-address-not-found)
			(asserts! (> amount-net u0) err-invalid-amount)
			(ok { parsed-tx: parsed-tx, order-script: order-script, fee: fee, amount-net: amount-net })))
(define-private (finalize-peg-in-common
	(tx (buff 4096))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (order-idx uint))
	(begin
		(asserts! (not (var-get peg-in-paused)) err-paused)
		(verify-mined tx block proof)))
(define-private (set-whitelisted-iter (e {owner: (buff 128), whitelisted: bool}) (launch-id uint))
	(begin  
		(map-set whitelisted {launch-id: launch-id, owner: (get owner e)} (get whitelisted e))
		launch-id))
(define-private (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) err-unauthorised)))
(define-private (max (a uint) (b uint))
  (if (< a b) b a)
)
(define-private (min (a uint) (b uint))
	(if (< a b) a b))
(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))
(define-private (div-down (a uint) (b uint))
	(if (is-eq a u0)
		u0
		(/ (* a ONE_8) b)))