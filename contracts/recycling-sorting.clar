;; Recycling Sorting Contract
;; Ensures proper waste category separation

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_INVALID_CATEGORY (err u301))
(define-constant ERR_CONTAMINATION_DETECTED (err u302))
(define-constant ERR_CONTAINER_NOT_FOUND (err u303))

;; Waste categories
(define-constant CATEGORY_PLASTIC "plastic")
(define-constant CATEGORY_GLASS "glass")
(define-constant CATEGORY_PAPER "paper")
(define-constant CATEGORY_METAL "metal")
(define-constant CATEGORY_ORGANIC "organic")
(define-constant CATEGORY_GENERAL "general")

;; Data Variables
(define-data-var next-sort-id uint u1)
(define-data-var contamination-penalty uint u10)
(define-data-var sorting-reward uint u5)

;; Data Maps
(define-map recycling-containers
  { container-id: uint }
  {
    designated-category: (string-ascii 20),
    location: (string-ascii 100),
    sorting-accuracy: uint,
    contamination-count: uint,
    total-deposits: uint,
    is-active: bool
  }
)

(define-map sorting-events
  { sort-id: uint }
  {
    container-id: uint,
    depositor: principal,
    waste-category: (string-ascii 20),
    weight: uint,
    timestamp: uint,
    is-correct: bool,
    verification-method: (string-ascii 30)
  }
)

(define-map contamination-reports
  { container-id: uint, report-time: uint }
  {
    reporter: principal,
    contamination-type: (string-ascii 50),
    severity: uint,
    corrective-action: (string-ascii 100),
    resolved: bool
  }
)

(define-map user-sorting-stats
  { user: principal }
  {
    correct-sorts: uint,
    incorrect-sorts: uint,
    total-weight-deposited: uint,
    rewards-earned: uint,
    penalties-incurred: uint
  }
)

(define-map category-definitions
  { category: (string-ascii 20) }
  {
    description: (string-ascii 200),
    accepted-items: (list 20 (string-ascii 50)),
    prohibited-items: (list 20 (string-ascii 50)),
    processing-fee: uint
  }
)

;; Public Functions

;; Register recycling container
(define-public (register-recycling-container (container-id uint) (category (string-ascii 20)) (location (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-valid-category category) ERR_INVALID_CATEGORY)

    (map-set recycling-containers
      { container-id: container-id }
      {
        designated-category: category,
        location: location,
        sorting-accuracy: u100,
        contamination-count: u0,
        total-deposits: u0,
        is-active: true
      }
    )
    (ok true)
  )
)

;; Record waste deposit
(define-public (record-deposit (container-id uint) (waste-category (string-ascii 20)) (weight uint) (verification-method (string-ascii 30)))
  (let (
    (sort-id (var-get next-sort-id))
    (container-data (unwrap! (map-get? recycling-containers { container-id: container-id }) ERR_CONTAINER_NOT_FOUND))
    (is-correct (is-eq waste-category (get designated-category container-data)))
  )
    (asserts! (is-valid-category waste-category) ERR_INVALID_CATEGORY)

    ;; Record the sorting event
    (map-set sorting-events
      { sort-id: sort-id }
      {
        container-id: container-id,
        depositor: tx-sender,
        waste-category: waste-category,
        weight: weight,
        timestamp: block-height,
        is-correct: is-correct,
        verification-method: verification-method
      }
    )

    ;; Update container stats
    (map-set recycling-containers
      { container-id: container-id }
      (merge container-data {
        total-deposits: (+ (get total-deposits container-data) u1),
        contamination-count: (if is-correct
          (get contamination-count container-data)
          (+ (get contamination-count container-data) u1)
        )
      })
    )

    ;; Update user stats and handle rewards/penalties
    (unwrap-panic (update-user-stats tx-sender is-correct weight))

    (var-set next-sort-id (+ sort-id u1))
    (ok sort-id)
  )
)

;; Report contamination
(define-public (report-contamination (container-id uint) (contamination-type (string-ascii 50)) (severity uint) (corrective-action (string-ascii 100)))
  (begin
    (asserts! (is-some (map-get? recycling-containers { container-id: container-id })) ERR_CONTAINER_NOT_FOUND)
    (asserts! (and (>= severity u1) (<= severity u5)) ERR_INVALID_CATEGORY)

    (map-set contamination-reports
      { container-id: container-id, report-time: block-height }
      {
        reporter: tx-sender,
        contamination-type: contamination-type,
        severity: severity,
        corrective-action: corrective-action,
        resolved: false
      }
    )
    (ok true)
  )
)

;; Resolve contamination
(define-public (resolve-contamination (container-id uint) (report-time uint))
  (let ((report-data (unwrap! (map-get? contamination-reports { container-id: container-id, report-time: report-time }) ERR_CONTAINER_NOT_FOUND)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)

    (map-set contamination-reports
      { container-id: container-id, report-time: report-time }
      (merge report-data { resolved: true })
    )
    (ok true)
  )
)

;; Define waste category
(define-public (define-category (category (string-ascii 20)) (description (string-ascii 200)) (accepted-items (list 20 (string-ascii 50))) (prohibited-items (list 20 (string-ascii 50))) (processing-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)

    (map-set category-definitions
      { category: category }
      {
        description: description,
        accepted-items: accepted-items,
        prohibited-items: prohibited-items,
        processing-fee: processing-fee
      }
    )
    (ok true)
  )
)

;; Private Functions

;; Update user statistics
(define-private (update-user-stats (user principal) (is-correct bool) (weight uint))
  (let ((current-stats (default-to
    { correct-sorts: u0, incorrect-sorts: u0, total-weight-deposited: u0, rewards-earned: u0, penalties-incurred: u0 }
    (map-get? user-sorting-stats { user: user })
  )))
    (map-set user-sorting-stats
      { user: user }
      {
        correct-sorts: (if is-correct (+ (get correct-sorts current-stats) u1) (get correct-sorts current-stats)),
        incorrect-sorts: (if is-correct (get incorrect-sorts current-stats) (+ (get incorrect-sorts current-stats) u1)),
        total-weight-deposited: (+ (get total-weight-deposited current-stats) weight),
        rewards-earned: (if is-correct (+ (get rewards-earned current-stats) (var-get sorting-reward)) (get rewards-earned current-stats)),
        penalties-incurred: (if is-correct (get penalties-incurred current-stats) (+ (get penalties-incurred current-stats) (var-get contamination-penalty)))
      }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Check if category is valid
(define-read-only (is-valid-category (category (string-ascii 20)))
  (or
    (is-eq category CATEGORY_PLASTIC)
    (or
      (is-eq category CATEGORY_GLASS)
      (or
        (is-eq category CATEGORY_PAPER)
        (or
          (is-eq category CATEGORY_METAL)
          (or
            (is-eq category CATEGORY_ORGANIC)
            (is-eq category CATEGORY_GENERAL)
          )
        )
      )
    )
  )
)

;; Get container data
(define-read-only (get-recycling-container (container-id uint))
  (map-get? recycling-containers { container-id: container-id })
)

;; Get sorting event
(define-read-only (get-sorting-event (sort-id uint))
  (map-get? sorting-events { sort-id: sort-id })
)

;; Get user stats
(define-read-only (get-user-stats (user principal))
  (map-get? user-sorting-stats { user: user })
)

;; Get contamination report
(define-read-only (get-contamination-report (container-id uint) (report-time uint))
  (map-get? contamination-reports { container-id: container-id, report-time: report-time })
)

;; Calculate sorting accuracy
(define-read-only (calculate-sorting-accuracy (container-id uint))
  (match (map-get? recycling-containers { container-id: container-id })
    container-data
    (let (
      (total-deposits (get total-deposits container-data))
      (contamination-count (get contamination-count container-data))
    )
      (if (is-eq total-deposits u0)
        u100
        (/ (* (- total-deposits contamination-count) u100) total-deposits)
      )
    )
    u0
  )
)

;; Get category definition
(define-read-only (get-category-definition (category (string-ascii 20)))
  (map-get? category-definitions { category: category })
)

;; Get next sort ID
(define-read-only (get-next-sort-id)
  (var-get next-sort-id)
)
