(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J)
(define-constant agent-2 'SP14NSM2BAB9MGMYNXJB93NY4EF4NFRW3G3EFBZDX)
(define-constant agent-3 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH)
(define-constant agent-4 'SP1JM5Y9J4T7J5XY9NX34SG1Z1BNAJT4H4NBHTPYD)
(define-constant agent-5 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant agent-6 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9)
(define-constant agent-7 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant agent-8 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2)
(define-constant agent-9 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP)
(define-constant agent-10 'SP1XZ7KEMJT5V8ATRYZB0XWJ20KMGM37JXJZG9D6S)
(define-constant agent-11 'SP2DFX28F1S3CB46B5XH9M5JQ7N4SMCE7CQY1TNYS)
(define-constant agent-12 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q)
(define-constant agent-13 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20)
(define-constant agent-14 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-15 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2)
(define-constant agent-16 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ)
(define-constant agent-17 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD)
(define-constant agent-18 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG)
(define-constant agent-0 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)
(define-data-var agent-4-status bool false)
(define-data-var agent-5-status bool false)
(define-data-var agent-6-status bool false)
(define-data-var agent-7-status bool false)
(define-data-var agent-8-status bool false)
(define-data-var agent-9-status bool false)
(define-data-var agent-10-status bool false)
(define-data-var agent-11-status bool false)
(define-data-var agent-12-status bool false)
(define-data-var agent-13-status bool false)
(define-data-var agent-14-status bool false)
(define-data-var agent-15-status bool false)
(define-data-var agent-16-status bool false)
(define-data-var agent-17-status bool false)
(define-data-var agent-18-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (as-contract (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u2844 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u2034 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u102 tx-sender agent-2)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3Z3GK22JHV7YYE479YVFAFQTX2XFSDJRPXG8GXF.posh-penguins transfer u97 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u739 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u517 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u438 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u518 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2414 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2339 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u2355 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.mutant-monkeys transfer u1958 tx-sender agent-3)))
		(as-contract (stx-transfer? u1767625 tx-sender agent-3)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u51821250 tx-sender agent-4)))
	)
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u862 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1063 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-giantpandas transfer u257 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u801 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u803 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u802 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.degen-naming-service transfer u23 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u1206 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u111 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u113 tx-sender agent-5)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u17000000 tx-sender agent-6)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2817 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3153 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2416 tx-sender agent-7)))
		(as-contract (stx-transfer? u10905500 tx-sender agent-7)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u854 tx-sender agent-8)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1069 tx-sender agent-8)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u909 tx-sender agent-8)))
	(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u235 tx-sender agent-8)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u70200000 tx-sender agent-9)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u9345375 tx-sender agent-10)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u9886 tx-sender agent-11)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u16003000 tx-sender agent-12)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u43875000 tx-sender agent-13)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u284678750 tx-sender agent-14)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u895 tx-sender agent-15)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u1639 tx-sender agent-15)))
	(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u126 tx-sender agent-15)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u5001750 tx-sender agent-16)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u6687 tx-sender agent-17)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u9216 tx-sender agent-17)))
	(unwrap-panic (as-contract (contract-call? 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft transfer u830 tx-sender agent-17)))
	(unwrap-panic (as-contract (contract-call? 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH.artificial-satoshi transfer u8 tx-sender agent-18)))
	(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u286 tx-sender agent-18)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u36608000 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u12610000 tx-sender agent-1)))
	)
	(var-set agent-1-status false)
	)
	true
	)
	(if (is-eq (var-get agent-2-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u2485625 tx-sender agent-2)))
	)
	(var-set agent-2-status false)
	)
	true
	)
	(if (is-eq (var-get agent-3-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u1639 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u895 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u111 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u113 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u1206 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u854 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH.artificial-satoshi transfer u8 tx-sender agent-3)))
	(var-set agent-3-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.degen-naming-service transfer u23 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SP3Z3GK22JHV7YYE479YVFAFQTX2XFSDJRPXG8GXF.posh-penguins transfer u97 tx-sender agent-4)))
	(var-set agent-4-status false))
	true)
	(if (is-eq (var-get agent-5-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u235 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u909 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u286 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u739 tx-sender agent-5)))
		(as-contract (stx-transfer? u107643125 tx-sender agent-5)))
	)
	(var-set agent-5-status false)
	)
	true
	)
	(if (is-eq (var-get agent-6-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u9886 tx-sender agent-6)))
	(var-set agent-6-status false))
	true)
	(if (is-eq (var-get agent-7-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u517 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u438 tx-sender agent-7)))
	(var-set agent-7-status false))
	true)
	(if (is-eq (var-get agent-8-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u102 tx-sender agent-8)))
		(as-contract (stx-transfer? u12976625 tx-sender agent-8)))
	)
	(var-set agent-8-status false)
	)
	true
	)
	(if (is-eq (var-get agent-9-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.mutant-monkeys transfer u1958 tx-sender agent-9)))
	(var-set agent-9-status false))
	true)
	(if (is-eq (var-get agent-10-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1063 tx-sender agent-10)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1069 tx-sender agent-10)))
	(var-set agent-10-status false))
	true)
	(if (is-eq (var-get agent-11-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u17860000 tx-sender agent-11)))
	)
	(var-set agent-11-status false)
	)
	true
	)
	(if (is-eq (var-get agent-12-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u126 tx-sender agent-12)))
		(unwrap-panic (as-contract (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u2844 tx-sender agent-12)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2416 tx-sender agent-12)))
	(var-set agent-12-status false))
	true)
	(if (is-eq (var-get agent-13-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u2355 tx-sender agent-13)))
	(var-set agent-13-status false))
	true)
	(if (is-eq (var-get agent-14-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u802 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u803 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u801 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft transfer u830 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2414 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2339 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u6687 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u9216 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u2034 tx-sender agent-14)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u862 tx-sender agent-14)))
	(var-set agent-14-status false))
	true)
	(if (is-eq (var-get agent-15-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u518 tx-sender agent-15)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2817 tx-sender agent-15)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3153 tx-sender agent-15)))
		(as-contract (stx-transfer? u145372750 tx-sender agent-15)))
	)
	(var-set agent-15-status false)
	)
	true
	)
	(if (is-eq (var-get agent-16-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-giantpandas transfer u257 tx-sender agent-16)))
	(var-set agent-16-status false))
	true)
	(if (is-eq (var-get agent-17-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u243825000 tx-sender agent-17)))
	)
	(var-set agent-17-status false)
	)
	true
	)
	(if (is-eq (var-get agent-18-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u4433125 tx-sender agent-18)))
	)
	(var-set agent-18-status false)
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
		(asserts! (is-ok (stx-transfer? u12610000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u2485625 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u1639 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u895 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u111 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u113 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u1206 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u854 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH.artificial-satoshi transfer u8 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.degen-naming-service transfer u23 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3Z3GK22JHV7YYE479YVFAFQTX2XFSDJRPXG8GXF.posh-penguins transfer u97 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u235 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u909 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u286 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u739 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u107643125 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u9886 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u517 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u438 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u102 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u12976625 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.mutant-monkeys transfer u1958 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1063 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1069 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u17860000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-11-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-12)
		(begin
		(asserts! (is-eq (var-get agent-12-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u126 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u2844 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2416 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-12-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-13)
		(begin
		(asserts! (is-eq (var-get agent-13-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u2355 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-13-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-14)
		(begin
		(asserts! (is-eq (var-get agent-14-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u802 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u803 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u801 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft transfer u830 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2414 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2339 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u6687 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u9216 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u2034 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u862 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-14-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-15)
		(begin
		(asserts! (is-eq (var-get agent-15-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u518 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2817 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3153 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u145372750 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-15-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-16)
		(begin
		(asserts! (is-eq (var-get agent-16-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-giantpandas transfer u257 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-16-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-17)
		(begin
		(asserts! (is-eq (var-get agent-17-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u243825000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-17-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-18)
		(begin
		(asserts! (is-eq (var-get agent-18-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u4433125 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-18-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10) (is-eq tx-sender agent-11) (is-eq tx-sender agent-12) (is-eq tx-sender agent-13) (is-eq tx-sender agent-14) (is-eq tx-sender agent-15) (is-eq tx-sender agent-16) (is-eq tx-sender agent-17) (is-eq tx-sender agent-18))
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