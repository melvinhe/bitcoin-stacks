(define-constant owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-public (jf-mass-transfer-1)
  (begin
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u623))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u624))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u626))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u637))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u638))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u639))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u558))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u559))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u599))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u560))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u600))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u561))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u609))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u390))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u408))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u618))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u619))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u621))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u629))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u632))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u605))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u407))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u604))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u685))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u603))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u598))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u602))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u601))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u607))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP12Q3YS92YCJGJY1MQSABJZHDZ6X77QX1YG47KZV u591)))
  )
)