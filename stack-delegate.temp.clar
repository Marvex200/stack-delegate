;; -----------------------------------------------------------
;; STACKDELEGATE - Identity Delegation Contract
;; Author: [Your Name or Team]
;; Description:
;;   A smart contract for identity delegation on the Stacks blockchain.
;;   Allows users (owners) to securely delegate permission to another
;;   wallet (delegate) for a specified duration (in blocks).
;; -----------------------------------------------------------

(define-constant ERR-CANNOT-DELEGATE-TO-SELF (err u100))
(define-constant ERR-DELEGATION-NOT-FOUND (err u101))
(define-constant ERR-DELEGATION-EXPIRED (err u102))

;; ------------------------
;; Data Structures
;; ------------------------

(define-map delegation-map
  ;; Key: owner (principal)
  ((owner principal))
  ;; Value: delegate and expiration block
  ((delegate principal) (expires-at uint))
)

;; ------------------------
;; Public Functions
;; ------------------------

(define-public (create-delegation (delegate principal) (duration uint))
  (begin
    (asserts! (not (is-eq tx-sender delegate)) ERR-CANNOT-DELEGATE-TO-SELF)
    (map-set delegation-map
      ((owner tx-sender))
      ((delegate delegate) (expires-at (+ block-height duration)))
    )
    (ok true)
  )
)

(define-public (revoke-delegation ())
  (begin
    (map-delete delegation-map ((owner tx-sender)))
    (ok true)
  )
)

;; ------------------------
;; Read-only Functions
;; ------------------------

(define-read-only (is-valid-delegate (owner principal) (querying principal))
  ;; Check if 'querying' is the current active delegate for 'owner'
  (let ((delegation-data (map-get? delegation-map ((owner owner)))))
    (if (is-some delegation-data)
      (let ((delegation (unwrap-panic delegation-data)))
        (ok
          (and
            (is-eq (get delegate delegation) querying)
            (>= (get expires-at delegation) block-height)
          )
        )
      )
      (ok false)
    )
  )
)

(define-read-only (get-delegation (owner principal))
  ;; Returns the current delegate and expiration block for 'owner'
  (map-get? delegation-map ((owner owner)))
)

;; ------------------------
;; Additional Helper Functions
;; ------------------------

(define-read-only (get-delegation-info (owner principal))
  ;; Returns delegation info with validity check
  (let ((delegation-data (map-get? delegation-map ((owner owner)))))
    (if (is-some delegation-data)
      (let ((delegation (unwrap-panic delegation-data)))
        (ok {
          delegate: (get delegate delegation),
          expires-at: (get expires-at delegation),
          is-active: (>= (get expires-at delegation) block-height)
        })
      )
      ERR-DELEGATION-NOT-FOUND
    )
  )
)

(define-read-only (is-delegation-expired (owner principal))
  ;; Check if a delegation exists and is expired
  (let ((delegation-data (map-get? delegation-map ((owner owner)))))
    (if (is-some delegation-data)
      (let ((delegation (unwrap-panic delegation-data)))
        (ok (< (get expires-at delegation) block-height))
      )
      ERR-DELEGATION-NOT-FOUND
    )
  )
)
