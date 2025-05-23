;; HODLBOX: Decentralized Time-Locked Asset Management
;; A time-locked vault contract for STX tokens


;; constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NO_VAULT (err u101))
(define-constant ERR_VAULT_LOCKED (err u102))
(define-constant ERR_INVALID_UNLOCK_TIME (err u103))
(define-constant ERR_ZERO_DEPOSIT (err u104))
(define-constant ERR_INSUFFICIENT_FUNDS (err u105))
(define-constant ERR_BENEFICIARY_ALREADY_SET (err u106))
(define-constant ERR_INVALID_BENEFICIARY (err u107))


;; Data structures
(define-map vaults
  { owner: principal }
  {
    balance: uint,
    unlock-height: uint,
    beneficiary: (optional principal)
  }
)

;; constants
;;
;; Helper functions

;; data vars
;;
;; Define our own max function since Clarity doesn't have a built-in max
(define-private (get-max (a uint) (b uint))
  (if (>= a b) a b)
)

;; data maps
;;
;; Read-only functions

;; public functions
;;
;; Get vault details for a user
(define-read-only (get-vault (owner principal))
  (default-to
    {
      balance: u0,
      unlock-height: u0,
      beneficiary: none
    }
    (map-get? vaults { owner: owner })
  )
)

;; read only functions
;;
;; Check if vault exists
(define-read-only (vault-exists (owner principal))
  (is-some (map-get? vaults { owner: owner }))
)

;; private functions
;;
;; Check if vault is unlocked
(define-read-only (is-vault-unlocked (owner principal))
  (let (
    (vault (get-vault owner))
    (current-height block-height)
  )
    (>= current-height (get unlock-height vault))
  )
)

;; Public functions

;; Create or add to vault with time lock
(define-public (deposit (amount uint) (unlock-height uint))
  (let (
    (sender tx-sender)
    (current-height block-height)
    (existing-vault (get-vault sender))
  )
    ;; Validate input parameters
    (asserts! (> amount u0) ERR_ZERO_DEPOSIT)
    (asserts! (> unlock-height current-height) ERR_INVALID_UNLOCK_TIME)

    ;; Check if vault exists
    (if (vault-exists sender)
      ;; If vault exists, update it
      (let (
        (new-balance (+ (get balance existing-vault) amount))
        (max-unlock-height (get-max unlock-height (get unlock-height existing-vault)))
      )
        ;; Transfer STX to contract
        (try! (stx-transfer? amount sender (as-contract tx-sender)))

        ;; Update vault
        (map-set vaults
          { owner: sender }
          {
            balance: new-balance,
            unlock-height: max-unlock-height,
            beneficiary: (get beneficiary existing-vault)
          }
        )
        (ok new-balance)
      )
      ;; If vault doesn't exist, create it
      (begin
        ;; Transfer STX to contract
        (try! (stx-transfer? amount sender (as-contract tx-sender)))

        ;; Create new vault
        (map-set vaults
          { owner: sender }
          {
            balance: amount,
            unlock-height: unlock-height,
            beneficiary: none
          }
        )
        (ok amount)
      )
    )
  )
)
