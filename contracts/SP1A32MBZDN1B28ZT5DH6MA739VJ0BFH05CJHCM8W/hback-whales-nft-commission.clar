(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u0)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin
            (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP28HPCDPVQ40JVQ1C52MQ23RPKBYGFHCR3NSAHX9)) ;;Save the whales
            (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2ETVY1D90HJQEQ7Z6X8N3C5DRG7XVQ5N3ZBKV6P)) ;;DAO
            (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP2XMYYK70WCW2V0VZE3ZW04MKN53KA1352GHVWQP)) ;;Team
            (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX)) ;;Marketplace
            (ok true)
        )
        (ok true)
    )
)