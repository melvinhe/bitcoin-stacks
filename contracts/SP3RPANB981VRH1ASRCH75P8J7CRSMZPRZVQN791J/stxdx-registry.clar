(define-public (register-asset (x uint)) (ok (match (contract-call? 'SP3RPANB981VRH1ASRCH75P8J7CRSMZPRZVQN791J.nakamoto-artifacts transfer x) r (ok r) r (err r))))