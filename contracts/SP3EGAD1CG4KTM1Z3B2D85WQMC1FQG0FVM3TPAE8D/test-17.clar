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

(print (get-vault-by-id u1521))
(print (get-vault-by-id u1522))
(print (get-vault-by-id u1523))
(print (get-vault-by-id u1524))
(print (get-vault-by-id u1525))
(print (get-vault-by-id u1526))
(print (get-vault-by-id u1527))
(print (get-vault-by-id u1528))
(print (get-vault-by-id u1529))
(print (get-vault-by-id u1530))
(print (get-vault-by-id u1531))
(print (get-vault-by-id u1532))
(print (get-vault-by-id u1533))
(print (get-vault-by-id u1534))
(print (get-vault-by-id u1535))
(print (get-vault-by-id u1536))
(print (get-vault-by-id u1537))
(print (get-vault-by-id u1538))
(print (get-vault-by-id u1539))
(print (get-vault-by-id u1540))
(print (get-vault-by-id u1541))
(print (get-vault-by-id u1542))
(print (get-vault-by-id u1543))
(print (get-vault-by-id u1544))
(print (get-vault-by-id u1545))
(print (get-vault-by-id u1546))
(print (get-vault-by-id u1547))
(print (get-vault-by-id u1548))
(print (get-vault-by-id u1549))
(print (get-vault-by-id u1550))
(print (get-vault-by-id u1551))
(print (get-vault-by-id u1552))
(print (get-vault-by-id u1553))
(print (get-vault-by-id u1554))
(print (get-vault-by-id u1555))
(print (get-vault-by-id u1556))
(print (get-vault-by-id u1557))
(print (get-vault-by-id u1558))
(print (get-vault-by-id u1559))
(print (get-vault-by-id u1560))
(print (get-vault-by-id u1561))
(print (get-vault-by-id u1562))
(print (get-vault-by-id u1563))
(print (get-vault-by-id u1564))
(print (get-vault-by-id u1565))
(print (get-vault-by-id u1566))
(print (get-vault-by-id u1567))
(print (get-vault-by-id u1568))
(print (get-vault-by-id u1569))
(print (get-vault-by-id u1570))
(print (get-vault-by-id u1571))
(print (get-vault-by-id u1572))
(print (get-vault-by-id u1573))
(print (get-vault-by-id u1574))
(print (get-vault-by-id u1575))
(print (get-vault-by-id u1576))
(print (get-vault-by-id u1577))
(print (get-vault-by-id u1578))
(print (get-vault-by-id u1579))
(print (get-vault-by-id u1580))
(print (get-vault-by-id u1581))
(print (get-vault-by-id u1582))
(print (get-vault-by-id u1583))
(print (get-vault-by-id u1584))
(print (get-vault-by-id u1585))
(print (get-vault-by-id u1586))
(print (get-vault-by-id u1587))
(print (get-vault-by-id u1588))
(print (get-vault-by-id u1589))
(print (get-vault-by-id u1590))
(print (get-vault-by-id u1591))
(print (get-vault-by-id u1592))
(print (get-vault-by-id u1593))
(print (get-vault-by-id u1594))
(print (get-vault-by-id u1595))
(print (get-vault-by-id u1596))
(print (get-vault-by-id u1597))
(print (get-vault-by-id u1598))
(print (get-vault-by-id u1599))
(print (get-vault-by-id u1600))
(print (get-vault-by-id u1601))
(print (get-vault-by-id u1602))
(print (get-vault-by-id u1603))
(print (get-vault-by-id u1604))
(print (get-vault-by-id u1605))
(print (get-vault-by-id u1606))
(print (get-vault-by-id u1607))
(print (get-vault-by-id u1608))
(print (get-vault-by-id u1609))
(print (get-vault-by-id u1610))
(print (get-vault-by-id u1611))
(print (get-vault-by-id u1612))
(print (get-vault-by-id u1613))
(print (get-vault-by-id u1614))
(print (get-vault-by-id u1615))