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

(print (get-vault-by-id u191))
(print (get-vault-by-id u192))
(print (get-vault-by-id u193))
(print (get-vault-by-id u194))
(print (get-vault-by-id u195))
(print (get-vault-by-id u196))
(print (get-vault-by-id u197))
(print (get-vault-by-id u198))
(print (get-vault-by-id u199))
(print (get-vault-by-id u200))
(print (get-vault-by-id u201))
(print (get-vault-by-id u202))
(print (get-vault-by-id u203))
(print (get-vault-by-id u204))
(print (get-vault-by-id u205))
(print (get-vault-by-id u206))
(print (get-vault-by-id u207))
(print (get-vault-by-id u208))
(print (get-vault-by-id u209))
(print (get-vault-by-id u210))
(print (get-vault-by-id u211))
(print (get-vault-by-id u212))
(print (get-vault-by-id u213))
(print (get-vault-by-id u214))
(print (get-vault-by-id u215))
(print (get-vault-by-id u216))
(print (get-vault-by-id u217))
(print (get-vault-by-id u218))
(print (get-vault-by-id u219))
(print (get-vault-by-id u220))
(print (get-vault-by-id u221))
(print (get-vault-by-id u222))
(print (get-vault-by-id u223))
(print (get-vault-by-id u224))
(print (get-vault-by-id u225))
(print (get-vault-by-id u226))
(print (get-vault-by-id u227))
(print (get-vault-by-id u228))
(print (get-vault-by-id u229))
(print (get-vault-by-id u230))
(print (get-vault-by-id u231))
(print (get-vault-by-id u232))
(print (get-vault-by-id u233))
(print (get-vault-by-id u234))
(print (get-vault-by-id u235))
(print (get-vault-by-id u236))
(print (get-vault-by-id u237))
(print (get-vault-by-id u238))
(print (get-vault-by-id u239))
(print (get-vault-by-id u240))
(print (get-vault-by-id u241))
(print (get-vault-by-id u242))
(print (get-vault-by-id u243))
(print (get-vault-by-id u244))
(print (get-vault-by-id u245))
(print (get-vault-by-id u246))
(print (get-vault-by-id u247))
(print (get-vault-by-id u248))
(print (get-vault-by-id u249))
(print (get-vault-by-id u250))
(print (get-vault-by-id u251))
(print (get-vault-by-id u252))
(print (get-vault-by-id u253))
(print (get-vault-by-id u254))
(print (get-vault-by-id u255))
(print (get-vault-by-id u256))
(print (get-vault-by-id u257))
(print (get-vault-by-id u258))
(print (get-vault-by-id u259))
(print (get-vault-by-id u260))
(print (get-vault-by-id u261))
(print (get-vault-by-id u262))
(print (get-vault-by-id u263))
(print (get-vault-by-id u264))
(print (get-vault-by-id u265))
(print (get-vault-by-id u266))
(print (get-vault-by-id u267))
(print (get-vault-by-id u268))
(print (get-vault-by-id u269))
(print (get-vault-by-id u270))
(print (get-vault-by-id u271))
(print (get-vault-by-id u272))
(print (get-vault-by-id u273))
(print (get-vault-by-id u274))
(print (get-vault-by-id u275))
(print (get-vault-by-id u276))
(print (get-vault-by-id u277))
(print (get-vault-by-id u278))
(print (get-vault-by-id u279))
(print (get-vault-by-id u280))
(print (get-vault-by-id u281))
(print (get-vault-by-id u282))
(print (get-vault-by-id u283))
(print (get-vault-by-id u284))
(print (get-vault-by-id u285))