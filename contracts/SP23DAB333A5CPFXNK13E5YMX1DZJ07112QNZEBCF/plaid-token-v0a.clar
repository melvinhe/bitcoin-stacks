;; wrap the native STX token into an SRC20 compatible token to be usable along other tokens
(impl-trait 'SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF.sip-010-v0a.ft-trait)

(define-fungible-token plaid)

;; get the token balance of owner
(define-read-only (get-balance-of (owner principal))
  (ok (ft-get-balance plaid owner))
)

;; returns the total number of tokens
;; TODO(psq): we don't have access yet, but once POX is available, this should be a value that
;; is available from Clarity
(define-read-only (get-total-supply)
  (ok (ft-get-supply plaid))
)

;; returns the token name
(define-read-only (get-name)
  (ok "Plaid")
)

(define-read-only (get-symbol)
  (ok "PLD")
)

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8)  ;; because we can, and interesting for testing wallets and other clients
)

(define-read-only (get-token-uri)
  (ok (some u"https://swapr.finance/tokens/plaid.json"))
)
;; {
;;   "name":"Plaid",
;;   "description":"Plaid token, used as a test token",
;;   "image":"https://swapr.finance/tokens/plaid.png",
;;   "vector":"https://swapr.finance/tokens/plaid.svg"
;; }


;; (transfer (uint principal principal) (response bool uint))
;; amount sender recipient
;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (print "plaid.transfer")
    (print amount)
    (print tx-sender)
    (print recipient)
    (asserts! (is-eq tx-sender sender) (err u255)) ;; too strict?
    (print (ft-transfer? plaid amount tx-sender recipient))
  )
)

;; TODO(psq): remove for mainnet, how???
(ft-mint? plaid u100000000000000 'SP3WZJAY2A398KKBT73M92PAGP5ZD2GE3JKC6KSSP)
(ft-mint? plaid u100000000 'SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF)
