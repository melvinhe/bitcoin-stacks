(define-public (bulk-transfer-megapont-ape-club-nft (ids (list 1000 uint)) (receivers (list 1000 principal))) (begin (print (map transfer ids receivers)) (ok true)))
(define-private (transfer (id uint) (receiver principal)) (contract-call? 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9.megapont-ape-club-nft transfer id tx-sender receiver))