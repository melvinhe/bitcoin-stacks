;; This contract implements the SIP-010 community-standard Fungible Token trait.
            (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
            
            ;; Define the FT, with no maximum supply
            (define-fungible-token odin)
            
            ;; Define errors
            (define-constant ERR_OWNER_ONLY (err u100))
            (define-constant ERR_NOT_TOKEN_OWNER (err u101))
            
            ;; Define constants for contract
            (define-constant CONTRACT_OWNER tx-sender)
            (define-constant TOKEN_URI u"https://token-metadat.s3.eu-central-1.amazonaws.com/asset.json") ;; utf-8 string with token metadata host
            (define-constant TOKEN_NAME "Odin")
            (define-constant TOKEN_SYMBOL "ODIN")
            (define-constant TOKEN_DECIMALS u6) ;; 6 units displayed past decimal, e.g. 1.000_000 = 1 token
            
            
            ;; SIP-010 function: Get the token balance of a specified principal
            (define-read-only (get-balance (who principal))
              (ok (ft-get-balance odin who))
            )
            
            ;; SIP-010 function: Returns the total supply of fungible token
            (define-read-only (get-total-supply)
              (ok (ft-get-supply odin))
            )
            
            ;; SIP-010 function: Returns the human-readable token name
            (define-read-only (get-name)
              (ok TOKEN_NAME)
            )
            
            ;; SIP-010 function: Returns the symbol or "ticker" for this token
            (define-read-only (get-symbol)
              (ok TOKEN_SYMBOL)
            )
            
            ;; SIP-010 function: Returns number of decimals to display
            (define-read-only (get-decimals)
              (ok TOKEN_DECIMALS)
            )
            
            ;; SIP-010 function: Returns the URI containing token metadata
            (define-read-only (get-token-uri)
              (ok (some TOKEN_URI))
            )
            ;; SIP-010 function: Transfers tokens to a recipient
            ;; Sender must be the same as the caller to prevent principals from transferring tokens they do not own.
            (define-public (transfer
              (amount uint)
              (sender principal)
              (recipient principal)
              (memo (optional (buff 34)))
            )
              (begin
                ;; #[filter(amount, recipient)]
                (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
                (try! (ft-transfer? odin amount sender recipient))
                (match memo to-print (print to-print) 0x)
                (ok true)
              )
            )
            
            ;; ---------------------------------------------------------
            ;; Utility Functions
            ;; ---------------------------------------------------------
            (define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
              (fold check-err (map send-token recipients) (ok true))
            )
            
            (define-private (check-err (result (response bool uint)) (prior (response bool uint)))
              (match prior ok-value result err-value (err err-value))
            )
            
            (define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
              (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
            )
            
            (define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
              (let ((transferOk (try! (transfer amount tx-sender to memo))))
                (ok transferOk)
              )
            )
            
            ;; Mint new tokens and send them to a recipient.
            ;; Only the contract deployer can perform this operation.
            (begin
              (ft-mint? odin u21000000000000000 CONTRACT_OWNER)
            )