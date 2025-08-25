;; Efficiency Recommendations Contract
;; Manages energy efficiency improvement recommendations and implementation tracking

;; Constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INVALID-STATUS (err u103))

;; Data Variables
(define-data-var contract-admin principal tx-sender)
(define-data-var next-recommendation-id uint u1)

;; Data Maps
(define-map recommendations
  { recommendation-id: uint }
  {
    building-id: uint,
    title: (string-ascii 100),
    description: (string-ascii 500),
    estimated-cost: uint,
    estimated-savings-percent: uint,
    priority-score: uint,
    category: (string-ascii 50),
    status: (string-ascii 20),
    created-by: principal,
    created-at: uint
  }
)

(define-map implementation-tracking
  { recommendation-id: uint }
  {
    actual-cost: uint,
    implementation-date: uint,
    verified-savings-percent: uint,
    implementation-notes: (string-ascii 500),
    implemented-by: principal,
    verified-by: principal,
    verified-at: uint
  }
)

(define-map building-recommendations
  { building-id: uint, recommendation-id: uint }
  { active: bool }
)

;; Private Functions
(define-private (is-admin (user principal))
  (is-eq user (var-get contract-admin))
)

(define-private (is-valid-status (status (string-ascii 20)))
  (or
    (is-eq status "PENDING")
    (is-eq status "APPROVED")
    (is-eq status "IMPLEMENTED")
    (is-eq status "VERIFIED")
    (is-eq status "REJECTED")
  )
)

(define-private (is-valid-priority (priority uint))
  (and (>= priority u1) (<= priority u10))
)

;; Public Functions
(define-public (add-recommendation
  (building-id uint)
  (title (string-ascii 100))
  (description (string-ascii 500))
  (estimated-cost uint)
  (estimated-savings-percent uint)
  (priority-score uint)
  (category (string-ascii 50))
)
  (let (
    (recommendation-id (var-get next-recommendation-id))
  )
    (asserts! (> building-id u0) ERR-INVALID-INPUT)
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> estimated-cost u0) ERR-INVALID-INPUT)
    (asserts! (<= estimated-savings-percent u100) ERR-INVALID-INPUT)
    (asserts! (is-valid-priority priority-score) ERR-INVALID-INPUT)
    (asserts! (> (len category) u0) ERR-INVALID-INPUT)

    (map-set recommendations
      { recommendation-id: recommendation-id }
      {
        building-id: building-id,
        title: title,
        description: description,
        estimated-cost: estimated-cost,
        estimated-savings-percent: estimated-savings-percent,
        priority-score: priority-score,
        category: category,
        status: "PENDING",
        created-by: tx-sender,
        created-at: block-height
      }
    )

    (map-set building-recommendations
      { building-id: building-id, recommendation-id: recommendation-id }
      { active: true }
    )

    (var-set next-recommendation-id (+ recommendation-id u1))
    (ok recommendation-id)
  )
)

(define-public (update-recommendation-status
  (recommendation-id uint)
  (new-status (string-ascii 20))
)
  (let (
    (recommendation-data (unwrap! (map-get? recommendations { recommendation-id: recommendation-id }) ERR-NOT-FOUND))
  )
    (asserts! (> recommendation-id u0) ERR-INVALID-INPUT)
    (asserts! (is-valid-status new-status) ERR-INVALID-INPUT)
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)

    (map-set recommendations
      { recommendation-id: recommendation-id }
      (merge recommendation-data { status: new-status })
    )

    (ok true)
  )
)

(define-public (implement-recommendation
  (recommendation-id uint)
  (actual-cost uint)
  (implementation-notes (string-ascii 500))
)
  (let (
    (recommendation-data (unwrap! (map-get? recommendations { recommendation-id: recommendation-id }) ERR-NOT-FOUND))
  )
    (asserts! (> recommendation-id u0) ERR-INVALID-INPUT)
    (asserts! (> actual-cost u0) ERR-INVALID-INPUT)
    (asserts! (is-eq (get status recommendation-data) "APPROVED") ERR-INVALID-STATUS)

    (map-set implementation-tracking
      { recommendation-id: recommendation-id }
      {
        actual-cost: actual-cost,
        implementation-date: block-height,
        verified-savings-percent: u0,
        implementation-notes: implementation-notes,
        implemented-by: tx-sender,
        verified-by: tx-sender,
        verified-at: u0
      }
    )

    (map-set recommendations
      { recommendation-id: recommendation-id }
      (merge recommendation-data { status: "IMPLEMENTED" })
    )

    (ok true)
  )
)

(define-public (verify-implementation
  (recommendation-id uint)
  (verified-savings-percent uint)
)
  (let (
    (recommendation-data (unwrap! (map-get? recommendations { recommendation-id: recommendation-id }) ERR-NOT-FOUND))
    (implementation-data (unwrap! (map-get? implementation-tracking { recommendation-id: recommendation-id }) ERR-NOT-FOUND))
  )
    (asserts! (> recommendation-id u0) ERR-INVALID-INPUT)
    (asserts! (<= verified-savings-percent u100) ERR-INVALID-INPUT)
    (asserts! (is-eq (get status recommendation-data) "IMPLEMENTED") ERR-INVALID-STATUS)
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)

    (map-set implementation-tracking
      { recommendation-id: recommendation-id }
      (merge implementation-data
        {
          verified-savings-percent: verified-savings-percent,
          verified-by: tx-sender,
          verified-at: block-height
        }
      )
    )

    (map-set recommendations
      { recommendation-id: recommendation-id }
      (merge recommendation-data { status: "VERIFIED" })
    )

    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-recommendation (recommendation-id uint))
  (map-get? recommendations { recommendation-id: recommendation-id })
)

(define-read-only (get-implementation-details (recommendation-id uint))
  (map-get? implementation-tracking { recommendation-id: recommendation-id })
)

(define-read-only (calculate-roi (recommendation-id uint) (annual-energy-cost uint))
  (match (map-get? implementation-tracking { recommendation-id: recommendation-id })
    implementation-data
      (let (
        (actual-cost (get actual-cost implementation-data))
        (savings-percent (get verified-savings-percent implementation-data))
        (annual-savings (/ (* annual-energy-cost savings-percent) u100))
      )
        (if (> annual-savings u0)
          (some (/ (* actual-cost u100) annual-savings))
          none
        )
      )
    none
  )
)

(define-read-only (get-recommendations-by-priority (min-priority uint))
  (ok min-priority)
)
