(define-constant OWNER tx-sender)

(define-constant LIST_300 (list
    u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 
    u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 
    u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 
    u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 
    u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 
    u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 
    u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 
    u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200 
    u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 
    u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250 
    u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 
    u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299 u300 
))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; data maps and vars ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-map bet-summary-map
  { bet-type: uint, round: uint }
  {
    start-at: uint,     ;; round start block
    start-time: uint,   ;; round start time-stamp roughly
    end-at: uint,       ;; round end block
    end-time: uint,     ;; round end time-stamp roughly
    p-num: uint,   ;; p number cur round
    v-num: uint,        ;; bet v times (v means left side [1-50])
    s-num: uint,        ;; bet s times (s means right side [51-100])
    rand-num: uint,     ;; the result random number
    total-s: uint  ;; total s of the winners
  }
)

(define-map bet-record-map
  { bet-type: uint, round: uint, index: uint } ;; index start from 1
  {
    p: principal,
    b: uint,    ;; 100*v+s
    s: uint,
    w: int        ;; 0 means not draw yet, >0 means win, <0 means lose
  }
)

(define-map bet-roundrecords-map
  { bet-type: uint, round: uint }
  (list 300 (optional {
      p: principal,
      b: uint,    ;; 100*v+s
      s: uint,
      w: int        ;; 0 means not draw yet, >0 means win, <0 means lose
    }
  ))
)

(define-data-var combine-bet-type uint u1)
(define-data-var combine-round uint u1)

(define-read-only (get-bet-record (index uint))
  (map-get? bet-record-map { bet-type: u1, round: u1, index: index })
)

(define-read-only (get-round-data-v2 (ll (list 100 (list 3 uint))))
  (map get-bet-record-v2 ll)
)

(define-read-only (get-bet-record-v2 (ll (list 3 uint)))
  (map-get? bet-record-map { bet-type: (unwrap-panic (element-at ll u0)), round: (unwrap-panic (element-at ll u1)), index: (unwrap-panic (element-at ll u2)) })
)

(define-public (combine-round-records (bet-type uint) (round uint))
  (begin
    (var-set combine-bet-type bet-type)
    (var-set combine-round round)
    (map-set bet-roundrecords-map { bet-type: bet-type, round: round } (map get-round-record LIST_300))
    (map del-round-record LIST_300)
    (ok true)
  )
)
(define-read-only (get-round-records (bet-type uint) (round uint))
  (map-get? bet-roundrecords-map { bet-type: bet-type, round: round })
)

(define-private (get-round-record (index uint))
  (map-get? bet-record-map { bet-type: (var-get combine-bet-type), round: (var-get combine-round), index: index })
)

(define-private (del-round-record (index uint))
  (map-delete bet-record-map { bet-type: (var-get combine-bet-type), round: (var-get combine-round), index: index })
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-private (set-record (index uint))
  (map-set bet-record-map
    { bet-type: u1, round: u1, index: index }
    {
      p: OWNER,
      b: index,
      s: u0,
      w: 0
    }
  )
)

(map-set bet-summary-map
  { bet-type: u1, round: u1 }
  {
    start-at: u0,
    start-time: u0,
    end-at: u0,
    end-time: u0,
    p-num: u2,
    v-num: u1,
    s-num: u1,
    rand-num: u0,
    total-s: u0
  }
)

(map set-record LIST_300)
(combine-round-records u1 u1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;