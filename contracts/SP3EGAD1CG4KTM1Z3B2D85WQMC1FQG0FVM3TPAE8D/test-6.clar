;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)

;;(define-data-var holders (string-ascii 256) "hi")


;;;;;;;;;;;;;;

(define-read-only (get-vault-by-id (vault-id uint))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vault-data-v1-1 get-vault-by-id vault-id)
)


(define-read-only (get-debt-for-vault (vault-id uint))
  (let ((vault (get-vault-by-id vault-id))) (ok (get debt vault)))
)

(print (get-vault-by-id u476))
(print (get-vault-by-id u477))
(print (get-vault-by-id u478))
(print (get-vault-by-id u479))
(print (get-vault-by-id u480))
(print (get-vault-by-id u481))
(print (get-vault-by-id u482))
(print (get-vault-by-id u483))
(print (get-vault-by-id u484))
(print (get-vault-by-id u485))
(print (get-vault-by-id u486))
(print (get-vault-by-id u487))
(print (get-vault-by-id u488))
(print (get-vault-by-id u489))
(print (get-vault-by-id u490))
(print (get-vault-by-id u491))
(print (get-vault-by-id u492))
(print (get-vault-by-id u493))
(print (get-vault-by-id u494))
(print (get-vault-by-id u495))
(print (get-vault-by-id u496))
(print (get-vault-by-id u497))
(print (get-vault-by-id u498))
(print (get-vault-by-id u499))
(print (get-vault-by-id u500))
(print (get-vault-by-id u501))
(print (get-vault-by-id u502))
(print (get-vault-by-id u503))
(print (get-vault-by-id u504))
(print (get-vault-by-id u505))
(print (get-vault-by-id u506))
(print (get-vault-by-id u507))
(print (get-vault-by-id u508))
(print (get-vault-by-id u509))
(print (get-vault-by-id u510))
(print (get-vault-by-id u511))
(print (get-vault-by-id u512))
(print (get-vault-by-id u513))
(print (get-vault-by-id u514))
(print (get-vault-by-id u515))
(print (get-vault-by-id u516))
(print (get-vault-by-id u517))
(print (get-vault-by-id u518))
(print (get-vault-by-id u519))
(print (get-vault-by-id u520))
(print (get-vault-by-id u521))
(print (get-vault-by-id u522))
(print (get-vault-by-id u523))
(print (get-vault-by-id u524))
(print (get-vault-by-id u525))
(print (get-vault-by-id u526))
(print (get-vault-by-id u527))
(print (get-vault-by-id u528))
(print (get-vault-by-id u529))
(print (get-vault-by-id u530))
(print (get-vault-by-id u531))
(print (get-vault-by-id u532))
(print (get-vault-by-id u533))
(print (get-vault-by-id u534))
(print (get-vault-by-id u535))
(print (get-vault-by-id u536))
(print (get-vault-by-id u537))
(print (get-vault-by-id u538))
(print (get-vault-by-id u539))
(print (get-vault-by-id u540))
(print (get-vault-by-id u541))
(print (get-vault-by-id u542))
(print (get-vault-by-id u543))
(print (get-vault-by-id u544))
(print (get-vault-by-id u545))
(print (get-vault-by-id u546))
(print (get-vault-by-id u547))
(print (get-vault-by-id u548))
(print (get-vault-by-id u549))
(print (get-vault-by-id u550))
(print (get-vault-by-id u551))
(print (get-vault-by-id u552))
(print (get-vault-by-id u553))
(print (get-vault-by-id u554))
(print (get-vault-by-id u555))
(print (get-vault-by-id u556))
(print (get-vault-by-id u557))
(print (get-vault-by-id u558))
(print (get-vault-by-id u559))
(print (get-vault-by-id u560))
(print (get-vault-by-id u561))
(print (get-vault-by-id u562))
(print (get-vault-by-id u563))
(print (get-vault-by-id u564))
(print (get-vault-by-id u565))
(print (get-vault-by-id u566))
(print (get-vault-by-id u567))
(print (get-vault-by-id u568))
(print (get-vault-by-id u569))
(print (get-vault-by-id u570))