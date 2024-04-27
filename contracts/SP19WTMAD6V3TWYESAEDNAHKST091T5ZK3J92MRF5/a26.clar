
;; constants
(define-constant IMAGE-HASH u"345a94125abb0a209a57943ffe043d101e810dbf52d08c892b4718613c867798")
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-COOLDOWN u102)
(define-constant CONTRACT-OWNER tx-sender)

(define-public (a15 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-9 b)))
    (b2 (unwrap-panic (swappy-18 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 (/ b2 u100)))
  )
)

(define-public (a13 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-15 (* b u100))))
    (b2 (unwrap-panic (swappy-20 b1)))
    (b3 (unwrap-panic (swappy-1 b2)))
    (b4 (unwrap-panic (swappy-7 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a3 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-29 b)))
    (b2 (unwrap-panic (swappy-23 b1)))
    (b3 (unwrap-panic (swappy-16 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a38 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-5 (* b u100))))
    (b2 (unwrap-panic (swappy-20 b1)))
    (b3 (unwrap-panic (swappy-16 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a10 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-15 (* b u100))))
    (b2 (unwrap-panic (swappy-20 b1)))
    (b3 (unwrap-panic (swappy-16 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a4 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-12 b1)))
    (b3 (unwrap-panic (swappy-11 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a9 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-12 b1)))
    (b3 (unwrap-panic (swappy-18 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a24 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-3 (* b u100))))
    (b2 (unwrap-panic (swappy-24 b1)))
    (b3 (unwrap-panic (swappy-30 b2)))
    (b4 (unwrap-panic (swappy-10 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a2 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-1 b1)))
    (b3 (unwrap-panic (swappy-7 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a12 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-29 b)))
    (b2 (unwrap-panic (swappy-23 b1)))
    (b3 (unwrap-panic (swappy-12 b2)))
    (b4 (unwrap-panic (swappy-18 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a11 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-29 b)))
    (b2 (unwrap-panic (swappy-23 b1)))
    (b3 (unwrap-panic (swappy-12 b2)))
    (b4 (unwrap-panic (swappy-2 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a5 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-9 b)))
    (b2 (unwrap-panic (swappy-20 b1)))
    (b3 (unwrap-panic (swappy-16 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a6 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-29 b)))
    (b2 (unwrap-panic (swappy-23 b1)))
    (b3 (unwrap-panic (swappy-12 b2)))
    (b4 (unwrap-panic (swappy-11 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a7 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-9 b)))
    (b2 (unwrap-panic (swappy-20 b1)))
    (b3 (unwrap-panic (swappy-1 b2)))
    (b4 (unwrap-panic (swappy-7 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a8 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-12 b1)))
    (b3 (unwrap-panic (swappy-2 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a14 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-5 (* b u100))))
    (b2 (unwrap-panic (swappy-20 b1)))
    (b3 (unwrap-panic (swappy-1 b2)))
    (b4 (unwrap-panic (swappy-7 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a20 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-30 (* b1 u100))))
    (b3 (unwrap-panic (swappy-10 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a19 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-30 (* b1 u100))))
    (b3 (unwrap-panic (swappy-22 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a17 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-21 (* b u100))))
    (b2 (unwrap-panic (swappy-14 b1)))
    (b3 (unwrap-panic (swappy-16 (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a31 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-17 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2))
  )
)

(define-public (a35 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-9 b)))
    (b2 (unwrap-panic (swappy-4 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2))
  )
)

(define-public (ua32 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-26 b)))
    (b2 (unwrap-panic (swappy-16 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2))
  )
)

(define-public (a16 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-5 (* b u100))))
    (b2 (unwrap-panic (swappy-11 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2))
  )
)

(define-public (a18 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-19 (* b u100))))
    (b2 (unwrap-panic (swappy-14 b1)))
    (b3 (unwrap-panic (swappy-16 (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a33 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-26 b)))
    (b2 (unwrap-panic (swappy-30 (* b1 u100))))
    (b3 (unwrap-panic (swappy-10 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a1 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-5 (* b u100))))
    (b2 (unwrap-panic (swappy-4 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2))
  )
)

(define-public (a34 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-19 (* b u100))))
    (b2 (unwrap-panic (swappy-14 b1)))
    (b3 (unwrap-panic (swappy-17 (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a36 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-13 b)))
    (b2 (unwrap-panic (swappy-11 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2))
  )
)

(define-public (a21 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-3 (* b u100))))
    (b2 (unwrap-panic (swappy-24 b1)))
    (b3 (unwrap-panic (swappy-16 (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3))
  )
)

(define-public (a25 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-19 (* b u100))))
    (b2 (unwrap-panic (swappy-14 b1)))
    (b3 (unwrap-panic (swappy-27 b2)))
    (b4 (unwrap-panic (swappy-25 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a26 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-27 (* b1 u100))))
    (b3 (unwrap-panic (swappy-25 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a22 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-21 (* b u100))))
    (b2 (unwrap-panic (swappy-14 b1)))
    (b3 (unwrap-panic (swappy-27 b2)))
    (b4 (unwrap-panic (swappy-25 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a29 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-21 (* b u100))))
    (b2 (unwrap-panic (swappy-8 b1)))
    (b3 (unwrap-panic (swappy-23 (/ b2 u100))))
    (b4 (unwrap-panic (swappy-16 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a37 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-13 b)))
    (b2 (unwrap-panic (swappy-18 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2))
  )
)

(define-public (a23 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-3 (* b u100))))
    (b2 (unwrap-panic (swappy-24 b1)))
    (b3 (unwrap-panic (swappy-30 b2)))
    (b4 (unwrap-panic (swappy-22 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a27 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-1 b1)))
    (b3 (unwrap-panic (swappy-28 (* b2 u100))))
    (b4 (unwrap-panic (swappy-22 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a28 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-6 b)))
    (b2 (unwrap-panic (swappy-1 b1)))
    (b3 (unwrap-panic (swappy-28 (* b2 u100))))
    (b4 (unwrap-panic (swappy-10 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a30 (x (list 5 uint)) (y (list 5 uint)) (z (list 5 uint)))
  (let (
    (a (unwrap-panic (element-at y (mod (var-get mop) u5))))
    (b (unwrap-panic (element-at x a)))
    (b1 (unwrap-panic (swappy-19 (* b u100))))
    (b2 (unwrap-panic (swappy-8 b1)))
    (b3 (unwrap-panic (swappy-23 (/ b2 u100))))
    (b4 (unwrap-panic (swappy-16 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (var-set mop (unwrap-panic (element-at z a)))
    (ok (list b b1 b2 b3 b4))
  )
)

(define-data-var mop uint u9)

(define-read-only (g-mop)
  (ok (var-get mop))
)

(define-public (swappy-1 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swappy-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swappy-3 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swappy-4 (dx uint))
  (let ((r (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-y-for-x 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token5 dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swappy-5 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swappy-6 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swappy-7 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swappy-8 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swappy-9 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swappy-10 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swappy-11 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swappy-12 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swappy-13 (dx uint))
  (let ((r (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token5 dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swappy-14 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swappy-15 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swappy-16 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swappy-17 (dx uint))
  (let ((r (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-y-for-x 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token3 dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swappy-18 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swappy-19 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swappy-20 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swappy-21 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swappy-22 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swappy-23 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swappy-24 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda u500000 dx (some u0)))))
  (ok r))
)

(define-public (swappy-25 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swappy-26 (dx uint))
  (let ((r (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token3 dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swappy-27 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u500000 dx (some u0)))))
  (ok r))
)

(define-public (swappy-28 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swappy-29 (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swappy-30 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dx r)))
)
