;; monsters-wl-one-prime
;; whitelist helper contract for monsters

(define-constant ERR-NOT-AUTHORIZED (err u408))

;; wl-1 
;; Monster Satoshibles Prime holders will be able to mint 2 free monsters per Prime they own on Stacks.
(define-map wl-one-prime uint bool)

;; public
(define-public (wl-one-set-minted (id uint))
    (begin
        (asserts! (is-eq contract-caller .monster-satoshibles) ERR-NOT-AUTHORIZED)
        (map-set wl-one-prime id true)
        (ok true)
    )
)

;; read-only
(define-read-only (wl-one-prime-is-minted (id uint))
  (default-to true (map-get? wl-one-prime id))
)

;; prime
(map-set wl-one-prime u666001 false)
(map-set wl-one-prime u666002 false)
(map-set wl-one-prime u666003 false)
(map-set wl-one-prime u666004 false)
(map-set wl-one-prime u666005 false)
(map-set wl-one-prime u666006 false)
(map-set wl-one-prime u666007 false)
(map-set wl-one-prime u666008 false)
(map-set wl-one-prime u666009 false)
(map-set wl-one-prime u666010 false)
(map-set wl-one-prime u666011 false)
(map-set wl-one-prime u666012 false)
(map-set wl-one-prime u666013 false)
(map-set wl-one-prime u666014 false)
(map-set wl-one-prime u666015 false)
(map-set wl-one-prime u666016 false)
(map-set wl-one-prime u666017 false)
(map-set wl-one-prime u666018 false)
(map-set wl-one-prime u666019 false)
(map-set wl-one-prime u666020 false)
(map-set wl-one-prime u666021 false)
(map-set wl-one-prime u666022 false)
(map-set wl-one-prime u666023 false)
(map-set wl-one-prime u666024 false)
(map-set wl-one-prime u666025 false)
(map-set wl-one-prime u666026 false)
(map-set wl-one-prime u666027 false)
(map-set wl-one-prime u666028 false)
(map-set wl-one-prime u666029 false)
(map-set wl-one-prime u666030 false)
(map-set wl-one-prime u666031 false)
(map-set wl-one-prime u666032 false)
(map-set wl-one-prime u666033 false)
(map-set wl-one-prime u666034 false)
(map-set wl-one-prime u666035 false)
(map-set wl-one-prime u666036 false)
(map-set wl-one-prime u666037 false)
(map-set wl-one-prime u666038 false)
(map-set wl-one-prime u666039 false)
(map-set wl-one-prime u666040 false)
(map-set wl-one-prime u666041 false)
(map-set wl-one-prime u666042 false)
(map-set wl-one-prime u666043 false)
(map-set wl-one-prime u666044 false)
(map-set wl-one-prime u666045 false)
(map-set wl-one-prime u666046 false)
(map-set wl-one-prime u666047 false)
(map-set wl-one-prime u666048 false)
(map-set wl-one-prime u666049 false)
(map-set wl-one-prime u666050 false)
(map-set wl-one-prime u666051 false)
(map-set wl-one-prime u666052 false)
(map-set wl-one-prime u666053 false)
(map-set wl-one-prime u666054 false)
(map-set wl-one-prime u666055 false)
(map-set wl-one-prime u666056 false)
(map-set wl-one-prime u666057 false)
(map-set wl-one-prime u666058 false)
(map-set wl-one-prime u666059 false)
(map-set wl-one-prime u666060 false)
(map-set wl-one-prime u666061 false)
(map-set wl-one-prime u666062 false)
(map-set wl-one-prime u666063 false)
(map-set wl-one-prime u666064 false)
(map-set wl-one-prime u666065 false)
(map-set wl-one-prime u666066 false)
(map-set wl-one-prime u666067 false)
(map-set wl-one-prime u666068 false)
(map-set wl-one-prime u666069 false)
(map-set wl-one-prime u666070 false)
(map-set wl-one-prime u666071 false)
(map-set wl-one-prime u666072 false)
(map-set wl-one-prime u666073 false)
(map-set wl-one-prime u666074 false)
(map-set wl-one-prime u666075 false)
(map-set wl-one-prime u666076 false)
(map-set wl-one-prime u666077 false)
(map-set wl-one-prime u666078 false)
(map-set wl-one-prime u666079 false)
(map-set wl-one-prime u666080 false)
(map-set wl-one-prime u666081 false)
(map-set wl-one-prime u666082 false)
(map-set wl-one-prime u666083 false)
(map-set wl-one-prime u666084 false)
(map-set wl-one-prime u666085 false)
(map-set wl-one-prime u666086 false)
(map-set wl-one-prime u666087 false)
(map-set wl-one-prime u666088 false)
(map-set wl-one-prime u666089 false)
(map-set wl-one-prime u666090 false)
(map-set wl-one-prime u666091 false)
(map-set wl-one-prime u666092 false)
(map-set wl-one-prime u666093 false)
(map-set wl-one-prime u666094 false)
(map-set wl-one-prime u666095 false)
(map-set wl-one-prime u666096 false)
(map-set wl-one-prime u666097 false)
(map-set wl-one-prime u666098 false)
(map-set wl-one-prime u666099 false)
(map-set wl-one-prime u666100 false)
(map-set wl-one-prime u666101 false)
(map-set wl-one-prime u666102 false)
(map-set wl-one-prime u666103 false)
(map-set wl-one-prime u666104 false)
(map-set wl-one-prime u666105 false)
(map-set wl-one-prime u666106 false)
(map-set wl-one-prime u666107 false)
(map-set wl-one-prime u666108 false)
(map-set wl-one-prime u666109 false)
(map-set wl-one-prime u666110 false)
(map-set wl-one-prime u666111 false)
(map-set wl-one-prime u666112 false)
(map-set wl-one-prime u666113 false)
(map-set wl-one-prime u666114 false)
(map-set wl-one-prime u666115 false)
(map-set wl-one-prime u666116 false)
(map-set wl-one-prime u666117 false)
(map-set wl-one-prime u666118 false)
(map-set wl-one-prime u666119 false)
(map-set wl-one-prime u666120 false)
(map-set wl-one-prime u666121 false)
(map-set wl-one-prime u666122 false)
(map-set wl-one-prime u666123 false)
(map-set wl-one-prime u666124 false)
(map-set wl-one-prime u666125 false)
(map-set wl-one-prime u666126 false)
(map-set wl-one-prime u666127 false)
(map-set wl-one-prime u666128 false)
(map-set wl-one-prime u666129 false)
(map-set wl-one-prime u666130 false)
(map-set wl-one-prime u666131 false)
(map-set wl-one-prime u666132 false)
(map-set wl-one-prime u666133 false)
(map-set wl-one-prime u666134 false)
(map-set wl-one-prime u666135 false)
(map-set wl-one-prime u666136 false)
(map-set wl-one-prime u666137 false)
(map-set wl-one-prime u666138 false)
(map-set wl-one-prime u666139 false)
(map-set wl-one-prime u666140 false)
(map-set wl-one-prime u666141 false)
(map-set wl-one-prime u666142 false)
(map-set wl-one-prime u666143 false)
(map-set wl-one-prime u666144 false)
(map-set wl-one-prime u666145 false)
(map-set wl-one-prime u666146 false)
(map-set wl-one-prime u666147 false)
(map-set wl-one-prime u666148 false)
(map-set wl-one-prime u666149 false)
(map-set wl-one-prime u666150 false)
(map-set wl-one-prime u666151 false)
(map-set wl-one-prime u666152 false)
(map-set wl-one-prime u666153 false)
(map-set wl-one-prime u666154 false)
(map-set wl-one-prime u666155 false)
(map-set wl-one-prime u666156 false)
(map-set wl-one-prime u666157 false)
(map-set wl-one-prime u666158 false)
(map-set wl-one-prime u666159 false)
(map-set wl-one-prime u666160 false)
(map-set wl-one-prime u666161 false)
(map-set wl-one-prime u666162 false)
(map-set wl-one-prime u666163 false)
(map-set wl-one-prime u666164 false)
(map-set wl-one-prime u666165 false)
(map-set wl-one-prime u666166 false)
(map-set wl-one-prime u666167 false)
(map-set wl-one-prime u666168 false)
(map-set wl-one-prime u666169 false)
(map-set wl-one-prime u666170 false)
(map-set wl-one-prime u666171 false)
(map-set wl-one-prime u666172 false)
(map-set wl-one-prime u666173 false)
(map-set wl-one-prime u666174 false)
(map-set wl-one-prime u666175 false)
(map-set wl-one-prime u666176 false)
(map-set wl-one-prime u666177 false)
(map-set wl-one-prime u666178 false)
(map-set wl-one-prime u666179 false)
(map-set wl-one-prime u666180 false)
(map-set wl-one-prime u666181 false)
(map-set wl-one-prime u666182 false)
(map-set wl-one-prime u666183 false)
(map-set wl-one-prime u666184 false)
(map-set wl-one-prime u666185 false)
(map-set wl-one-prime u666186 false)
(map-set wl-one-prime u666187 false)
(map-set wl-one-prime u666188 false)
(map-set wl-one-prime u666189 false)
(map-set wl-one-prime u666190 false)
(map-set wl-one-prime u666191 false)
(map-set wl-one-prime u666192 false)
(map-set wl-one-prime u666193 false)
(map-set wl-one-prime u666194 false)
(map-set wl-one-prime u666195 false)
(map-set wl-one-prime u666196 false)
(map-set wl-one-prime u666197 false)
(map-set wl-one-prime u666198 false)
(map-set wl-one-prime u666199 false)
(map-set wl-one-prime u666200 false)
(map-set wl-one-prime u666201 false)
(map-set wl-one-prime u666202 false)
(map-set wl-one-prime u666203 false)
(map-set wl-one-prime u666204 false)
(map-set wl-one-prime u666205 false)
(map-set wl-one-prime u666206 false)
(map-set wl-one-prime u666207 false)
(map-set wl-one-prime u666208 false)
(map-set wl-one-prime u666209 false)
(map-set wl-one-prime u666210 false)
(map-set wl-one-prime u666211 false)
(map-set wl-one-prime u666212 false)
(map-set wl-one-prime u666213 false)
(map-set wl-one-prime u666214 false)
(map-set wl-one-prime u666215 false)
(map-set wl-one-prime u666216 false)
(map-set wl-one-prime u666217 false)
(map-set wl-one-prime u666218 false)
(map-set wl-one-prime u666219 false)
(map-set wl-one-prime u666220 false)
(map-set wl-one-prime u666221 false)
(map-set wl-one-prime u666222 false)
(map-set wl-one-prime u666223 false)
(map-set wl-one-prime u666224 false)
(map-set wl-one-prime u666225 false)
(map-set wl-one-prime u666226 false)
(map-set wl-one-prime u666227 false)
(map-set wl-one-prime u666228 false)
(map-set wl-one-prime u666229 false)
(map-set wl-one-prime u666230 false)
(map-set wl-one-prime u666231 false)
(map-set wl-one-prime u666232 false)
(map-set wl-one-prime u666233 false)
(map-set wl-one-prime u666234 false)
(map-set wl-one-prime u666235 false)
(map-set wl-one-prime u666236 false)
(map-set wl-one-prime u666237 false)
(map-set wl-one-prime u666238 false)
(map-set wl-one-prime u666239 false)
(map-set wl-one-prime u666240 false)
(map-set wl-one-prime u666241 false)
(map-set wl-one-prime u666242 false)
(map-set wl-one-prime u666243 false)
(map-set wl-one-prime u666244 false)
(map-set wl-one-prime u666245 false)
(map-set wl-one-prime u666246 false)
(map-set wl-one-prime u666247 false)
(map-set wl-one-prime u666248 false)
(map-set wl-one-prime u666249 false)
(map-set wl-one-prime u666250 false)
(map-set wl-one-prime u666251 false)
(map-set wl-one-prime u666252 false)
(map-set wl-one-prime u666253 false)
(map-set wl-one-prime u666254 false)
(map-set wl-one-prime u666255 false)
(map-set wl-one-prime u666256 false)
(map-set wl-one-prime u666257 false)
(map-set wl-one-prime u666258 false)
(map-set wl-one-prime u666259 false)
(map-set wl-one-prime u666260 false)
(map-set wl-one-prime u666261 false)
(map-set wl-one-prime u666262 false)
(map-set wl-one-prime u666263 false)
(map-set wl-one-prime u666264 false)
(map-set wl-one-prime u666265 false)
(map-set wl-one-prime u666266 false)
(map-set wl-one-prime u666267 false)
(map-set wl-one-prime u666268 false)
(map-set wl-one-prime u666269 false)
(map-set wl-one-prime u666270 false)
(map-set wl-one-prime u666271 false)
(map-set wl-one-prime u666272 false)
(map-set wl-one-prime u666273 false)
(map-set wl-one-prime u666274 false)
(map-set wl-one-prime u666275 false)
(map-set wl-one-prime u666276 false)
(map-set wl-one-prime u666277 false)
(map-set wl-one-prime u666278 false)
(map-set wl-one-prime u666279 false)
(map-set wl-one-prime u666280 false)
(map-set wl-one-prime u666281 false)
(map-set wl-one-prime u666282 false)
(map-set wl-one-prime u666283 false)
(map-set wl-one-prime u666284 false)
(map-set wl-one-prime u666285 false)
(map-set wl-one-prime u666286 false)
(map-set wl-one-prime u666287 false)
(map-set wl-one-prime u666288 false)
(map-set wl-one-prime u666289 false)
(map-set wl-one-prime u666290 false)
(map-set wl-one-prime u666291 false)
(map-set wl-one-prime u666292 false)
(map-set wl-one-prime u666293 false)
(map-set wl-one-prime u666294 false)
(map-set wl-one-prime u666295 false)
(map-set wl-one-prime u666296 false)
(map-set wl-one-prime u666297 false)
(map-set wl-one-prime u666298 false)
(map-set wl-one-prime u666299 false)
(map-set wl-one-prime u666300 false)
(map-set wl-one-prime u666301 false)
(map-set wl-one-prime u666302 false)
(map-set wl-one-prime u666303 false)
(map-set wl-one-prime u666304 false)
(map-set wl-one-prime u666305 false)
(map-set wl-one-prime u666306 false)
(map-set wl-one-prime u666307 false)
(map-set wl-one-prime u666308 false)
(map-set wl-one-prime u666309 false)
(map-set wl-one-prime u666310 false)
(map-set wl-one-prime u666311 false)
(map-set wl-one-prime u666312 false)
(map-set wl-one-prime u666313 false)
(map-set wl-one-prime u666314 false)
(map-set wl-one-prime u666315 false)
(map-set wl-one-prime u666316 false)
(map-set wl-one-prime u666317 false)
(map-set wl-one-prime u666318 false)
(map-set wl-one-prime u666319 false)
(map-set wl-one-prime u666320 false)
(map-set wl-one-prime u666321 false)
(map-set wl-one-prime u666322 false)
(map-set wl-one-prime u666323 false)
(map-set wl-one-prime u666324 false)
(map-set wl-one-prime u666325 false)
(map-set wl-one-prime u666326 false)
(map-set wl-one-prime u666327 false)
(map-set wl-one-prime u666328 false)
(map-set wl-one-prime u666329 false)
(map-set wl-one-prime u666330 false)
(map-set wl-one-prime u666331 false)
(map-set wl-one-prime u666332 false)
(map-set wl-one-prime u666333 false)
(map-set wl-one-prime u666334 false)
(map-set wl-one-prime u666335 false)
(map-set wl-one-prime u666336 false)
(map-set wl-one-prime u666337 false)
(map-set wl-one-prime u666338 false)
(map-set wl-one-prime u666339 false)
(map-set wl-one-prime u666340 false)
(map-set wl-one-prime u666341 false)
(map-set wl-one-prime u666342 false)
(map-set wl-one-prime u666343 false)
(map-set wl-one-prime u666344 false)
(map-set wl-one-prime u666345 false)
(map-set wl-one-prime u666346 false)
(map-set wl-one-prime u666347 false)
(map-set wl-one-prime u666348 false)
(map-set wl-one-prime u666349 false)
(map-set wl-one-prime u666350 false)
(map-set wl-one-prime u666351 false)
(map-set wl-one-prime u666352 false)
(map-set wl-one-prime u666353 false)
(map-set wl-one-prime u666354 false)
(map-set wl-one-prime u666355 false)
(map-set wl-one-prime u666356 false)
(map-set wl-one-prime u666357 false)
(map-set wl-one-prime u666358 false)
(map-set wl-one-prime u666359 false)
(map-set wl-one-prime u666360 false)
(map-set wl-one-prime u666361 false)
(map-set wl-one-prime u666362 false)
(map-set wl-one-prime u666363 false)
(map-set wl-one-prime u666364 false)
(map-set wl-one-prime u666365 false)
(map-set wl-one-prime u666366 false)
(map-set wl-one-prime u666367 false)
(map-set wl-one-prime u666368 false)
(map-set wl-one-prime u666369 false)
(map-set wl-one-prime u666370 false)
(map-set wl-one-prime u666371 false)
(map-set wl-one-prime u666372 false)
(map-set wl-one-prime u666373 false)
(map-set wl-one-prime u666374 false)
(map-set wl-one-prime u666375 false)
(map-set wl-one-prime u666376 false)
(map-set wl-one-prime u666377 false)
(map-set wl-one-prime u666378 false)
(map-set wl-one-prime u666379 false)
(map-set wl-one-prime u666380 false)
(map-set wl-one-prime u666381 false)
(map-set wl-one-prime u666382 false)
(map-set wl-one-prime u666383 false)
(map-set wl-one-prime u666384 false)
(map-set wl-one-prime u666385 false)
(map-set wl-one-prime u666386 false)
(map-set wl-one-prime u666387 false)
(map-set wl-one-prime u666388 false)
(map-set wl-one-prime u666389 false)
(map-set wl-one-prime u666390 false)
(map-set wl-one-prime u666391 false)
(map-set wl-one-prime u666392 false)
(map-set wl-one-prime u666393 false)
(map-set wl-one-prime u666394 false)
(map-set wl-one-prime u666395 false)
(map-set wl-one-prime u666396 false)
(map-set wl-one-prime u666397 false)
(map-set wl-one-prime u666398 false)
(map-set wl-one-prime u666399 false)
(map-set wl-one-prime u666400 false)
(map-set wl-one-prime u666401 false)
(map-set wl-one-prime u666402 false)
(map-set wl-one-prime u666403 false)
(map-set wl-one-prime u666404 false)
(map-set wl-one-prime u666405 false)
(map-set wl-one-prime u666406 false)
(map-set wl-one-prime u666407 false)
(map-set wl-one-prime u666408 false)
(map-set wl-one-prime u666409 false)
(map-set wl-one-prime u666410 false)
(map-set wl-one-prime u666411 false)
(map-set wl-one-prime u666412 false)
(map-set wl-one-prime u666413 false)
(map-set wl-one-prime u666414 false)
(map-set wl-one-prime u666415 false)
(map-set wl-one-prime u666416 false)
(map-set wl-one-prime u666417 false)
(map-set wl-one-prime u666418 false)
(map-set wl-one-prime u666419 false)
(map-set wl-one-prime u666420 false)
(map-set wl-one-prime u666421 false)
(map-set wl-one-prime u666422 false)
(map-set wl-one-prime u666423 false)
(map-set wl-one-prime u666424 false)
(map-set wl-one-prime u666425 false)
(map-set wl-one-prime u666426 false)
(map-set wl-one-prime u666427 false)
(map-set wl-one-prime u666428 false)
(map-set wl-one-prime u666429 false)
(map-set wl-one-prime u666430 false)
(map-set wl-one-prime u666431 false)
(map-set wl-one-prime u666432 false)
(map-set wl-one-prime u666433 false)
(map-set wl-one-prime u666434 false)
(map-set wl-one-prime u666435 false)
(map-set wl-one-prime u666436 false)
(map-set wl-one-prime u666437 false)
(map-set wl-one-prime u666438 false)
(map-set wl-one-prime u666439 false)
(map-set wl-one-prime u666440 false)
(map-set wl-one-prime u666441 false)
(map-set wl-one-prime u666442 false)
(map-set wl-one-prime u666443 false)
(map-set wl-one-prime u666444 false)
(map-set wl-one-prime u666445 false)
(map-set wl-one-prime u666446 false)
(map-set wl-one-prime u666447 false)
(map-set wl-one-prime u666448 false)
(map-set wl-one-prime u666449 false)
(map-set wl-one-prime u666450 false)
(map-set wl-one-prime u666451 false)
(map-set wl-one-prime u666452 false)
(map-set wl-one-prime u666453 false)
(map-set wl-one-prime u666454 false)
(map-set wl-one-prime u666455 false)
(map-set wl-one-prime u666456 false)
(map-set wl-one-prime u666457 false)
(map-set wl-one-prime u666458 false)
(map-set wl-one-prime u666459 false)
(map-set wl-one-prime u666460 false)
(map-set wl-one-prime u666461 false)
(map-set wl-one-prime u666462 false)
(map-set wl-one-prime u666463 false)
(map-set wl-one-prime u666464 false)
(map-set wl-one-prime u666465 false)
(map-set wl-one-prime u666466 false)
(map-set wl-one-prime u666467 false)
(map-set wl-one-prime u666468 false)
(map-set wl-one-prime u666469 false)
(map-set wl-one-prime u666470 false)
(map-set wl-one-prime u666471 false)
(map-set wl-one-prime u666472 false)
(map-set wl-one-prime u666473 false)
(map-set wl-one-prime u666474 false)
(map-set wl-one-prime u666475 false)
(map-set wl-one-prime u666476 false)
(map-set wl-one-prime u666477 false)
(map-set wl-one-prime u666478 false)
(map-set wl-one-prime u666479 false)
(map-set wl-one-prime u666480 false)
(map-set wl-one-prime u666481 false)
(map-set wl-one-prime u666482 false)
(map-set wl-one-prime u666483 false)
(map-set wl-one-prime u666484 false)
(map-set wl-one-prime u666485 false)
(map-set wl-one-prime u666486 false)
(map-set wl-one-prime u666487 false)
(map-set wl-one-prime u666488 false)
(map-set wl-one-prime u666489 false)
(map-set wl-one-prime u666490 false)
(map-set wl-one-prime u666491 false)
(map-set wl-one-prime u666492 false)
(map-set wl-one-prime u666493 false)
(map-set wl-one-prime u666494 false)
(map-set wl-one-prime u666495 false)
(map-set wl-one-prime u666496 false)
(map-set wl-one-prime u666497 false)
(map-set wl-one-prime u666498 false)
(map-set wl-one-prime u666499 false)
(map-set wl-one-prime u666500 false)
(map-set wl-one-prime u666501 false)
(map-set wl-one-prime u666502 false)
(map-set wl-one-prime u666503 false)
(map-set wl-one-prime u666504 false)
(map-set wl-one-prime u666505 false)
(map-set wl-one-prime u666506 false)
(map-set wl-one-prime u666507 false)
(map-set wl-one-prime u666508 false)
(map-set wl-one-prime u666509 false)
(map-set wl-one-prime u666510 false)
(map-set wl-one-prime u666511 false)
(map-set wl-one-prime u666512 false)
(map-set wl-one-prime u666513 false)
(map-set wl-one-prime u666514 false)
(map-set wl-one-prime u666515 false)
(map-set wl-one-prime u666516 false)
(map-set wl-one-prime u666517 false)
(map-set wl-one-prime u666518 false)
(map-set wl-one-prime u666519 false)
(map-set wl-one-prime u666520 false)
(map-set wl-one-prime u666521 false)
(map-set wl-one-prime u666522 false)
(map-set wl-one-prime u666523 false)
(map-set wl-one-prime u666524 false)
(map-set wl-one-prime u666525 false)
(map-set wl-one-prime u666526 false)
(map-set wl-one-prime u666527 false)
(map-set wl-one-prime u666528 false)
(map-set wl-one-prime u666529 false)
(map-set wl-one-prime u666530 false)
(map-set wl-one-prime u666531 false)
(map-set wl-one-prime u666532 false)
(map-set wl-one-prime u666533 false)
(map-set wl-one-prime u666534 false)
(map-set wl-one-prime u666535 false)
(map-set wl-one-prime u666536 false)
(map-set wl-one-prime u666537 false)
(map-set wl-one-prime u666538 false)
(map-set wl-one-prime u666539 false)
(map-set wl-one-prime u666540 false)
(map-set wl-one-prime u666541 false)
(map-set wl-one-prime u666542 false)
(map-set wl-one-prime u666543 false)
(map-set wl-one-prime u666544 false)
(map-set wl-one-prime u666545 false)
(map-set wl-one-prime u666546 false)
(map-set wl-one-prime u666547 false)
(map-set wl-one-prime u666548 false)
(map-set wl-one-prime u666549 false)
(map-set wl-one-prime u666550 false)
(map-set wl-one-prime u666551 false)
(map-set wl-one-prime u666552 false)
(map-set wl-one-prime u666553 false)
(map-set wl-one-prime u666554 false)
(map-set wl-one-prime u666555 false)
(map-set wl-one-prime u666556 false)
(map-set wl-one-prime u666557 false)
(map-set wl-one-prime u666558 false)
(map-set wl-one-prime u666559 false)
(map-set wl-one-prime u666560 false)
(map-set wl-one-prime u666561 false)
(map-set wl-one-prime u666562 false)
(map-set wl-one-prime u666563 false)
(map-set wl-one-prime u666564 false)
(map-set wl-one-prime u666565 false)
(map-set wl-one-prime u666566 false)
(map-set wl-one-prime u666567 false)
(map-set wl-one-prime u666568 false)
(map-set wl-one-prime u666569 false)
(map-set wl-one-prime u666570 false)
(map-set wl-one-prime u666571 false)
(map-set wl-one-prime u666572 false)
(map-set wl-one-prime u666573 false)
(map-set wl-one-prime u666574 false)
(map-set wl-one-prime u666575 false)
(map-set wl-one-prime u666576 false)
(map-set wl-one-prime u666577 false)
(map-set wl-one-prime u666578 false)
(map-set wl-one-prime u666579 false)
(map-set wl-one-prime u666580 false)
(map-set wl-one-prime u666581 false)
(map-set wl-one-prime u666582 false)
(map-set wl-one-prime u666583 false)
(map-set wl-one-prime u666584 false)
(map-set wl-one-prime u666585 false)
(map-set wl-one-prime u666586 false)
(map-set wl-one-prime u666587 false)
(map-set wl-one-prime u666588 false)
(map-set wl-one-prime u666589 false)
(map-set wl-one-prime u666590 false)
(map-set wl-one-prime u666591 false)
(map-set wl-one-prime u666592 false)
(map-set wl-one-prime u666593 false)
(map-set wl-one-prime u666594 false)
(map-set wl-one-prime u666595 false)
(map-set wl-one-prime u666596 false)
(map-set wl-one-prime u666597 false)
(map-set wl-one-prime u666598 false)
(map-set wl-one-prime u666599 false)
(map-set wl-one-prime u666600 false)
(map-set wl-one-prime u666601 false)
(map-set wl-one-prime u666602 false)
(map-set wl-one-prime u666603 false)
(map-set wl-one-prime u666604 false)
(map-set wl-one-prime u666605 false)
(map-set wl-one-prime u666606 false)
(map-set wl-one-prime u666607 false)
(map-set wl-one-prime u666608 false)
(map-set wl-one-prime u666609 false)
(map-set wl-one-prime u666610 false)
(map-set wl-one-prime u666611 false)
(map-set wl-one-prime u666612 false)
(map-set wl-one-prime u666613 false)
(map-set wl-one-prime u666614 false)
(map-set wl-one-prime u666615 false)
(map-set wl-one-prime u666616 false)
(map-set wl-one-prime u666617 false)
(map-set wl-one-prime u666618 false)
(map-set wl-one-prime u666619 false)
(map-set wl-one-prime u666620 false)
(map-set wl-one-prime u666621 false)
(map-set wl-one-prime u666622 false)
(map-set wl-one-prime u666623 false)
(map-set wl-one-prime u666624 false)
(map-set wl-one-prime u666625 false)
(map-set wl-one-prime u666626 false)
(map-set wl-one-prime u666627 false)
(map-set wl-one-prime u666628 false)
(map-set wl-one-prime u666629 false)
(map-set wl-one-prime u666630 false)
(map-set wl-one-prime u666631 false)
(map-set wl-one-prime u666632 false)
(map-set wl-one-prime u666633 false)
(map-set wl-one-prime u666634 false)
(map-set wl-one-prime u666635 false)
(map-set wl-one-prime u666636 false)
(map-set wl-one-prime u666637 false)
(map-set wl-one-prime u666638 false)
(map-set wl-one-prime u666639 false)
(map-set wl-one-prime u666640 false)
(map-set wl-one-prime u666641 false)
(map-set wl-one-prime u666642 false)
(map-set wl-one-prime u666643 false)
(map-set wl-one-prime u666644 false)
(map-set wl-one-prime u666645 false)
(map-set wl-one-prime u666646 false)
(map-set wl-one-prime u666647 false)
(map-set wl-one-prime u666648 false)
(map-set wl-one-prime u666649 false)
(map-set wl-one-prime u666650 false)
(map-set wl-one-prime u666651 false)
(map-set wl-one-prime u666652 false)
(map-set wl-one-prime u666653 false)
(map-set wl-one-prime u666654 false)
(map-set wl-one-prime u666655 false)
(map-set wl-one-prime u666656 false)
(map-set wl-one-prime u666657 false)
(map-set wl-one-prime u666658 false)
(map-set wl-one-prime u666659 false)
(map-set wl-one-prime u666660 false)
(map-set wl-one-prime u666661 false)
(map-set wl-one-prime u666662 false)
(map-set wl-one-prime u666663 false)
(map-set wl-one-prime u666664 false)
(map-set wl-one-prime u666665 false)
(map-set wl-one-prime u666666 false)