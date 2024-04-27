;; Title: Multi-Fap

(use-trait executor-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisafe-traits.executor-trait) 
(use-trait safe-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisafe-traits.safe-trait)

(impl-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisafe-traits.safe-trait)

;; Errors
(define-constant ERR-CALLER-MUST-BE-SELF (err u100))
(define-constant ERR-OWNER-ALREADY-EXISTS (err u110))
(define-constant ERR-OWNER-NOT-EXISTS (err u120))
(define-constant ERR-UNAUTHORIZED-SENDER (err u130))
(define-constant ERR-TX-NOT-FOUND (err u140))
(define-constant ERR-TX-ALREADY-CONFIRMED-BY-OWNER (err u150))
(define-constant ERR-TX-INVALID-EXECUTOR (err u160))
(define-constant ERR-INVALID-SAFE (err u170))
(define-constant ERR-TX-CONFIRMED (err u180))
(define-constant ERR-TX-NOT-CONFIRMED-BY-SENDER (err u190))
(define-constant ERR-AT-LEAST-ONE-OWNER-REQUIRED (err u200))
(define-constant ERR-MIN-CONFIRMATION-CANT-BE-ZERO (err u210))


;; Principal of deployed contract
(define-constant SELF (as-contract tx-sender))

;; --- Version

;; Version string
(define-constant VERSION "0.0.69.doge")

;; Returns version of the safe contract
;; @returns string-ascii
(define-read-only (get-version) 
    VERSION
)

;; --- Owners

;; The owners list
(define-data-var owners (list 20 principal) (list)) 

;; Returns owner list
;; @returns list
(define-read-only (get-owners)
    (var-get owners)
)

;; Private function to push a new member to the owners list
;; @params owner
;; @returns bool
(define-private (add-owner-internal (owner principal))
    (var-set owners (unwrap-panic (as-max-len? (append (var-get owners) owner) u20)))
)

;; Adds new owner
;; @restricted to SELF
;; @params owner
;; @returns (response bool)
(define-public (add-owner (owner principal))
    (begin
        (asserts! (is-eq tx-sender SELF) ERR-CALLER-MUST-BE-SELF)
        (asserts! (is-none (index-of (var-get owners) owner)) ERR-OWNER-ALREADY-EXISTS)
        (ok (add-owner-internal owner))
    )
)

;; A helper variable to filter owners while removing one
(define-data-var rem-owner principal tx-sender)

;; Returns a new owner list removing the given as parameter
;; @param owner
;; @returns list
(define-private (remove-owner-filter (owner principal)) (not (is-eq owner (var-get rem-owner))))

;; Removes an owner
;; @restricted to SELF
;; @params owner
;; @returns (response bool)
(define-public (remove-owner (owner principal))
    (let
        (
            (owners-list (var-get owners))
        )
        (asserts! (is-eq tx-sender SELF) ERR-CALLER-MUST-BE-SELF)
        (asserts! (is-some (index-of owners-list owner)) ERR-OWNER-NOT-EXISTS)
        (asserts! (> (len owners-list) u1) ERR-AT-LEAST-ONE-OWNER-REQUIRED)
        (var-set rem-owner owner)
        (ok (var-set owners (unwrap-panic (as-max-len? (filter remove-owner-filter owners-list) u20))))
    )
)


;; --- Minimum confirmation requirement 

(define-data-var min-confirmation uint u0)

;; Returns minimum confirmation
;; @returns uint 
(define-read-only (get-min-confirmation)
    (var-get min-confirmation)
)

;; Private function to set minimum required confirmation number
;; @params value
;; return bool
(define-private (set-min-confirmation-internal (value uint))
    (var-set min-confirmation value)
)

;; Updates minimum required confirmation number
;; @restricted to SELF
;; @params value
;; @returns (response bool)
(define-public (set-min-confirmation (value uint))
    (begin
        (asserts! (is-eq tx-sender SELF) ERR-CALLER-MUST-BE-SELF)
        (asserts! (> value u0) ERR-MIN-CONFIRMATION-CANT-BE-ZERO)
        (ok (set-min-confirmation-internal value))
    )
)

;; --- Nonce

;; Incrementing number to use as id for new transactions
(define-data-var nonce uint u0)

;; Returns nonce 
;; @returns uint
(define-read-only (get-nonce)
 (var-get nonce)
)

;; Increases nonce
;; @returns bool
(define-private (increase-nonce)
    (var-set nonce (+ (var-get nonce) u1))
)

;; --- Transactions

(define-map transactions 
    uint 
    {
        executor: principal,
        confirmations: (list 20 principal),
        confirmed: bool,
        param-p: principal,
        param-u: uint
    }
)

;; Private function to insert a new transaction into transactions map
;; @params executor ; contract address to be executed
;; @params param-p ; principal parameter to be passed to the executor function
;; @params param-u ; uint argument to be passed to the executor function
;; @returns uint
(define-private (add (executor <executor-trait>) (param-p principal) (param-u uint))
    (let 
        (
            (tx-id (get-nonce))
        ) 
        (map-insert transactions tx-id {executor: (contract-of executor), confirmations: (list), confirmed: false, param-p: param-p, param-u: param-u})
        (increase-nonce)
        tx-id
    )
)

;; Returns a transaction by id
;; @params tx-id ; transaction id
;; @returns tuple
(define-read-only (get-transaction (tx-id uint))
    (unwrap-panic (map-get? transactions tx-id))
)

;; Returns transactions by ids
;; @params tx-ids ; transaction id list
;; @returns list
(define-read-only (get-transactions (tx-ids (list 20 uint)))
    (map get-transaction tx-ids)
)

;; A helper variable to filter confirmations while removing one
(define-data-var rem-confirmation principal tx-sender)

;; Returns a new confirmations list removing the given as parameter
;; @param owner
;; @returns list
(define-private (remove-confirmation-filter (owner principal)) (not (is-eq owner (var-get rem-confirmation))))


;; Allows an owner to remove their confirmation on the transaction
;; @restricted to owner who confirmed the transaction before
;; @params tx-id ; transaction id
;; @returns (response bool)
(define-public (revoke (tx-id uint))
    (let 
        (
            (tx (unwrap! (map-get? transactions tx-id) ERR-TX-NOT-FOUND))
            (confirmations (get confirmations tx))
        )
        (asserts! (is-eq (get confirmed tx) false) ERR-TX-CONFIRMED)
        (asserts! (is-some (index-of confirmations tx-sender)) ERR-TX-NOT-CONFIRMED-BY-SENDER)
        (var-set rem-confirmation tx-sender)
        (let 
            (
                (new-confirmations  (unwrap-panic (as-max-len? (filter remove-confirmation-filter confirmations) u20)))
                (new-tx (merge tx {confirmations: new-confirmations}))
            )
            (map-set transactions tx-id new-tx)
            (print {action: "multisafe-revoke", sender: tx-sender, tx-id: tx-id})
            (ok true)
        )
    )
)


;; Allows an owner to confirm a tranaction. If the transaction reaches sufficient confirmation number 
;; then the executor specified on the transaction gets triggered.
;; @restricted to owners who hasn't confirmed the transaction yet
;; @params executor ; contract address to be executed
;; @params safe ; address of safe instance / SELF
;; @returns (response bool)
(define-public (confirm (tx-id uint) (executor <executor-trait>) (safe <safe-trait>))
    (begin
        (asserts! (is-some (index-of (var-get owners) tx-sender)) ERR-UNAUTHORIZED-SENDER)
        (asserts! (is-eq (contract-of safe) SELF) ERR-INVALID-SAFE) 
        (let
            (
                (tx (unwrap! (map-get? transactions tx-id) ERR-TX-NOT-FOUND))
                (confirmations (get confirmations tx))
            )

            (asserts! (is-none (index-of confirmations tx-sender)) ERR-TX-ALREADY-CONFIRMED-BY-OWNER)
            (asserts! (is-eq (get executor tx) (contract-of executor)) ERR-TX-INVALID-EXECUTOR)
            
            (let 
                (
                    (new-confirmations (unwrap-panic (as-max-len? (append confirmations tx-sender) u20)))
                    (confirmed (>= (len new-confirmations) (var-get min-confirmation)))
                    (new-tx (merge tx {confirmations: new-confirmations, confirmed: confirmed}))
                )
                (map-set transactions tx-id new-tx)
                (and confirmed (try! (as-contract (contract-call? executor execute safe (get param-p tx) (get param-u tx)))))
                (print {action: "multisafe-confirmation", sender: tx-sender, tx-id: tx-id, confirmed: confirmed})
                (ok confirmed)
            )
        )
    )
)

;; Allows an owner to add a new transaction and confirms it for the owner who submitted it. 
;; So, a newly submitted transaction gets one confirmation automatically. If the safe's minimum
;; required confirmation number is one then the transaction gets executed in this step.
;; @restricted to owners
;; @params executor ; contract address to be executed
;; @params safe ; address of safe instance / SELF
;; @params param-p ; principal parameter to be passed to the executor function
;; @params param-u ; uint argument to be passed to the executor function
;; @returns (response uint)
(define-public (submit (executor <executor-trait>) (safe <safe-trait>) (param-p principal) (param-u uint))
    (begin
        (asserts! (is-some (index-of (var-get owners) tx-sender)) ERR-UNAUTHORIZED-SENDER)
        (asserts! (is-eq (contract-of safe) SELF) ERR-INVALID-SAFE) 
        (let
            ((tx-id (add executor param-p param-u)))
            (print {action: "multisafe-submit", sender: tx-sender, tx-id: tx-id, executor: executor, param-p: param-p, param-u: param-u})
            (unwrap-panic (confirm tx-id executor safe))
            (ok tx-id)
        )
    )
)


;; Safe initializer
;; @params o ; owners list
;; @params m ; minimum required confirmation number
(define-private (init (o (list 20 principal)) (m uint))
    (begin
        (map add-owner-internal o)
        (set-min-confirmation-internal m)
        (print {action: "multisafe-init"})
    )
)

(init (list
 'SP69MS8W17WWT6MNH8AB4A7BMY5AX6MAMWD89CCR
 'SP2V6HR6CTCKYSBC47F1V6D1FMCSHJ0SXM0MJZYVY
 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH
 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6
 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X
 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9
 'SP3XJTH5TJ3PEE67T02AA4DSBC89A80S028SQS769
 'SPBQ5AB9W17MHXJYP67CZNYBPKFPMTFN1JBHHV2G
 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A
 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW 
) u4)