(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-USER-NOT-FOUND (err u101))
(define-constant ERR-INSUFFICIENT-ENERGY (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-PANEL-NOT-FOUND (err u104))
(define-constant ERR-GRID-NOT-FOUND (err u105))
(define-constant ERR-TRADE-NOT-FOUND (err u106))
(define-constant ERR-INSUFFICIENT-BALANCE (err u107))
(define-constant ERR-INVALID-PRICE (err u108))
(define-constant ERR-MAINTENANCE-REQUIRED (err u109))
(define-constant ERR-ALREADY-EXISTS (err u110))

(define-data-var contract-owner principal tx-sender)
(define-data-var total-energy-produced uint u0)
(define-data-var total-energy-consumed uint u0)
(define-data-var platform-fee-rate uint u250)
(define-data-var grid-maintenance-fund uint u0)

(define-map users principal {
    energy-balance: uint,
    reputation: uint,
    total-produced: uint,
    total-consumed: uint,
    rewards-earned: uint,
    joined-at: uint
})

(define-map solar-panels uint {
    owner: principal,
    capacity: uint,
    efficiency: uint,
    location: (string-ascii 50),
    installation-date: uint,
    maintenance-due: uint,
    total-generated: uint,
    status: (string-ascii 20)
})

(define-map microgrids uint {
    name: (string-ascii 50),
    manager: principal,
    total-capacity: uint,
    current-load: uint,
    participants: uint,
    grid-fee: uint,
    created-at: uint,
    status: (string-ascii 20)
})

(define-map grid-participants { grid-id: uint, participant: principal } {
    joined-at: uint,
    contribution: uint,
    consumption: uint
})

(define-map energy-trades uint {
    seller: principal,
    buyer: (optional principal),
    amount: uint,
    price-per-unit: uint,
    total-price: uint,
    grid-id: uint,
    created-at: uint,
    expires-at: uint,
    status: (string-ascii 20)
})

(define-map energy-transactions uint {
    from: principal,
    to: principal,
    amount: uint,
    price: uint,
    trade-id: uint,
    timestamp: uint,
    transaction-type: (string-ascii 20)
})

(define-data-var next-panel-id uint u1)
(define-data-var next-grid-id uint u1)
(define-data-var next-trade-id uint u1)
(define-data-var next-transaction-id uint u1)

(define-public (register-user)
    (let ((caller tx-sender))
        (if (is-some (map-get? users caller))
            (err u110)
            (begin
                (map-set users caller {
                    energy-balance: u0,
                    reputation: u100,
                    total-produced: u0,
                    total-consumed: u0,
                    rewards-earned: u0,
                    joined-at: stacks-block-height
                })
                (ok true)))))

(define-public (install-solar-panel (capacity uint) (efficiency uint) (location (string-ascii 50)))
    (let ((panel-id (var-get next-panel-id))
          (caller tx-sender))
        (if (< capacity u1)
            ERR-INVALID-AMOUNT
            (begin
                (map-set solar-panels panel-id {
                    owner: caller,
                    capacity: capacity,
                    efficiency: efficiency,
                    location: location,
                    installation-date: stacks-block-height,
                    maintenance-due: (+ stacks-block-height u52560),
                    total-generated: u0,
                    status: "active"
                })
                (var-set next-panel-id (+ panel-id u1))
                (ok panel-id)))))

(define-public (create-microgrid (name (string-ascii 50)) (grid-fee uint))
    (let ((grid-id (var-get next-grid-id))
          (caller tx-sender))
        (begin
            (map-set microgrids grid-id {
                name: name,
                manager: caller,
                total-capacity: u0,
                current-load: u0,
                participants: u1,
                grid-fee: grid-fee,
                created-at: stacks-block-height,
                status: "active"
            })
            (map-set grid-participants { grid-id: grid-id, participant: caller } {
                joined-at: stacks-block-height,
                contribution: u0,
                consumption: u0
            })
            (var-set next-grid-id (+ grid-id u1))
            (ok grid-id))))

(define-public (join-microgrid (grid-id uint))
    (let ((caller tx-sender)
          (grid-data (unwrap! (map-get? microgrids grid-id) ERR-GRID-NOT-FOUND)))
        (if (is-some (map-get? grid-participants { grid-id: grid-id, participant: caller }))
            (err u110)
            (begin
                (map-set grid-participants { grid-id: grid-id, participant: caller } {
                    joined-at: stacks-block-height,
                    contribution: u0,
                    consumption: u0
                })
                (map-set microgrids grid-id 
                    (merge grid-data { participants: (+ (get participants grid-data) u1) }))
                (ok true)))))

(define-public (record-energy-production (panel-id uint) (amount uint))
    (let ((panel-data (unwrap! (map-get? solar-panels panel-id) ERR-PANEL-NOT-FOUND))
          (caller tx-sender)
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND)))
        (if (not (is-eq caller (get owner panel-data)))
            ERR-NOT-AUTHORIZED
            (if (< amount u1)
                ERR-INVALID-AMOUNT
                (let ((reward-amount (/ (* amount (get efficiency panel-data)) u100)))
                    (map-set solar-panels panel-id 
                        (merge panel-data { total-generated: (+ (get total-generated panel-data) amount) }))
                    (map-set users caller {
                        energy-balance: (+ (get energy-balance user-data) amount),
                        reputation: (+ (get reputation user-data) u1),
                        total-produced: (+ (get total-produced user-data) amount),
                        total-consumed: (get total-consumed user-data),
                        rewards-earned: (+ (get rewards-earned user-data) reward-amount),
                        joined-at: (get joined-at user-data)
                    })
                    (var-set total-energy-produced (+ (var-get total-energy-produced) amount))
                    (ok amount))))))

(define-public (consume-energy (amount uint))
    (let ((caller tx-sender)
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND)))
        (if (< amount u1)
            ERR-INVALID-AMOUNT
            (if (< (get energy-balance user-data) amount)
                ERR-INSUFFICIENT-ENERGY
                (begin
                    (map-set users caller {
                        energy-balance: (- (get energy-balance user-data) amount),
                        reputation: (get reputation user-data),
                        total-produced: (get total-produced user-data),
                        total-consumed: (+ (get total-consumed user-data) amount),
                        rewards-earned: (get rewards-earned user-data),
                        joined-at: (get joined-at user-data)
                    })
                    (var-set total-energy-consumed (+ (var-get total-energy-consumed) amount))
                    (ok amount))))))

(define-public (create-energy-trade (amount uint) (price-per-unit uint) (grid-id uint) (expires-in uint))
    (let ((trade-id (var-get next-trade-id))
          (caller tx-sender)
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND))
          (grid-data (unwrap! (map-get? microgrids grid-id) ERR-GRID-NOT-FOUND)))
        (if (or (< amount u1) (< price-per-unit u1))
            ERR-INVALID-AMOUNT
            (if (< (get energy-balance user-data) amount)
                ERR-INSUFFICIENT-ENERGY
                (let ((total-price (* amount price-per-unit))
                      (expires-at (+ stacks-block-height expires-in)))
                    (map-set energy-trades trade-id {
                        seller: caller,
                        buyer: none,
                        amount: amount,
                        price-per-unit: price-per-unit,
                        total-price: total-price,
                        grid-id: grid-id,
                        created-at: stacks-block-height,
                        expires-at: expires-at,
                        status: "active"
                    })
                    (var-set next-trade-id (+ trade-id u1))
                    (ok trade-id))))))

(define-public (purchase-energy (trade-id uint))
    (let ((trade-data (unwrap! (map-get? energy-trades trade-id) ERR-TRADE-NOT-FOUND))
          (caller tx-sender)
          (buyer-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND))
          (seller-data (unwrap! (map-get? users (get seller trade-data)) ERR-USER-NOT-FOUND)))
        (if (not (is-eq (get status trade-data) "active"))
            ERR-TRADE-NOT-FOUND
            (if (> stacks-block-height (get expires-at trade-data))
                ERR-TRADE-NOT-FOUND
                (let ((platform-fee (/ (* (get total-price trade-data) (var-get platform-fee-rate)) u10000))
                      (seller-amount (- (get total-price trade-data) platform-fee))
                      (transaction-id (var-get next-transaction-id)))
                    (map-set users (get seller trade-data) {
                        energy-balance: (- (get energy-balance seller-data) (get amount trade-data)),
                        reputation: (+ (get reputation seller-data) u2),
                        total-produced: (get total-produced seller-data),
                        total-consumed: (get total-consumed seller-data),
                        rewards-earned: (+ (get rewards-earned seller-data) seller-amount),
                        joined-at: (get joined-at seller-data)
                    })
                    (map-set users caller {
                        energy-balance: (+ (get energy-balance buyer-data) (get amount trade-data)),
                        reputation: (+ (get reputation buyer-data) u1),
                        total-produced: (get total-produced buyer-data),
                        total-consumed: (get total-consumed buyer-data),
                        rewards-earned: (get rewards-earned buyer-data),
                        joined-at: (get joined-at buyer-data)
                    })
                    (map-set energy-trades trade-id 
                        (merge trade-data { buyer: (some caller), status: "completed" }))
                    (map-set energy-transactions transaction-id {
                        from: (get seller trade-data),
                        to: caller,
                        amount: (get amount trade-data),
                        price: (get total-price trade-data),
                        trade-id: trade-id,
                        timestamp: stacks-block-height,
                        transaction-type: "purchase"
                    })
                    (var-set grid-maintenance-fund (+ (var-get grid-maintenance-fund) platform-fee))
                    (var-set next-transaction-id (+ transaction-id u1))
                    (ok transaction-id))))))

(define-public (schedule-panel-maintenance (panel-id uint))
    (let ((panel-data (unwrap! (map-get? solar-panels panel-id) ERR-PANEL-NOT-FOUND))
          (caller tx-sender))
        (if (not (is-eq caller (get owner panel-data)))
            ERR-NOT-AUTHORIZED
            (begin
                (map-set solar-panels panel-id 
                    (merge panel-data { 
                        maintenance-due: (+ stacks-block-height u52560),
                        status: "maintenance"
                    }))
                (ok true)))))

(define-public (complete-panel-maintenance (panel-id uint))
    (let ((panel-data (unwrap! (map-get? solar-panels panel-id) ERR-PANEL-NOT-FOUND))
          (caller tx-sender))
        (if (not (is-eq caller (get owner panel-data)))
            ERR-NOT-AUTHORIZED
            (begin
                (map-set solar-panels panel-id 
                    (merge panel-data { status: "active" }))
                (ok true)))))

(define-public (transfer-energy (recipient principal) (amount uint))
    (let ((caller tx-sender)
          (sender-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND))
          (recipient-data (unwrap! (map-get? users recipient) ERR-USER-NOT-FOUND))
          (transaction-id (var-get next-transaction-id)))
        (if (< amount u1)
            ERR-INVALID-AMOUNT
            (if (< (get energy-balance sender-data) amount)
                ERR-INSUFFICIENT-ENERGY
                (begin
                    (map-set users caller {
                        energy-balance: (- (get energy-balance sender-data) amount),
                        reputation: (get reputation sender-data),
                        total-produced: (get total-produced sender-data),
                        total-consumed: (get total-consumed sender-data),
                        rewards-earned: (get rewards-earned sender-data),
                        joined-at: (get joined-at sender-data)
                    })
                    (map-set users recipient {
                        energy-balance: (+ (get energy-balance recipient-data) amount),
                        reputation: (get reputation recipient-data),
                        total-produced: (get total-produced recipient-data),
                        total-consumed: (get total-consumed recipient-data),
                        rewards-earned: (get rewards-earned recipient-data),
                        joined-at: (get joined-at recipient-data)
                    })
                    (map-set energy-transactions transaction-id {
                        from: caller,
                        to: recipient,
                        amount: amount,
                        price: u0,
                        trade-id: u0,
                        timestamp: stacks-block-height,
                        transaction-type: "transfer"
                    })
                    (var-set next-transaction-id (+ transaction-id u1))
                    (ok transaction-id))))))

(define-read-only (get-user-data (user principal))
    (map-get? users user))

(define-read-only (get-panel-data (panel-id uint))
    (map-get? solar-panels panel-id))

(define-read-only (get-microgrid-data (grid-id uint))
    (map-get? microgrids grid-id))

(define-read-only (get-trade-data (trade-id uint))
    (map-get? energy-trades trade-id))

(define-read-only (get-transaction-data (transaction-id uint))
    (map-get? energy-transactions transaction-id))

(define-read-only (get-grid-participant (grid-id uint) (participant principal))
    (map-get? grid-participants { grid-id: grid-id, participant: participant }))

(define-read-only (get-platform-stats)
    {
        total-energy-produced: (var-get total-energy-produced),
        total-energy-consumed: (var-get total-energy-consumed),
        platform-fee-rate: (var-get platform-fee-rate),
        grid-maintenance-fund: (var-get grid-maintenance-fund),
        next-panel-id: (var-get next-panel-id),
        next-grid-id: (var-get next-grid-id),
        next-trade-id: (var-get next-trade-id)
    })

(define-read-only (calculate-grid-efficiency (grid-id uint))
    (let ((grid-data (unwrap! (map-get? microgrids grid-id) (err u0))))
        (if (> (get total-capacity grid-data) u0)
            (ok (/ (* (get current-load grid-data) u100) (get total-capacity grid-data)))
            (ok u0))))

(define-read-only (get-energy-balance (user principal))
    (match (map-get? users user)
        user-data (ok (get energy-balance user-data))
        (err u101)))

(define-public (update-platform-fee (new-rate uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (<= new-rate u1000) ERR-INVALID-AMOUNT)
        (var-set platform-fee-rate new-rate)
        (ok true)))