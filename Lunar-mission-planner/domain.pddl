(define (domain lunar)
    (:requirements :strips :typing)

    ; ---------------------------------
    ; Types
    ; ---------------------------------
    (:types
        lander
        rover
        waypoint
        sample
        data
    )

    ; ---------------------------------
    ; Predicates
    ; ---------------------------------
    (:predicates
        (positioned ?r - rover ?w - waypoint)       ; Rover ?r is currently at waypoint ?w
        (lander-at ?ld - lander ?w - waypoint)      ; Lander ?ld is currently at waypoint ?w
        (path ?w1 - waypoint ?w2 - waypoint)       ; There is a path from waypoint ?w1 to waypoint ?w2
        (activated ?r - rover)                      ; Rover ?r has been activated
        (idle ?r - rover)                           ; Rover ?r has free memory and is ready to collect data
        (carrying-data ?r - rover ?d - data)       ; Rover ?r is carrying data ?d
        (data-sent ?d - data ?ld - lander)         ; Data ?d has been sent to lander ?ld
        (holding-sample ?r - rover ?s - sample)    ; Rover ?r is holding sample ?s
        (stored-sample ?ld - lander ?s - sample)   ; Lander ?ld has stored sample ?s
        (photo-site ?d - data ?w - waypoint)       ; Data ?d (photo) must be collected at waypoint ?w
        (scan-site ?d - data ?w - waypoint)        ; Data ?d (scan) must be collected at waypoint ?w
        (sample-site ?s - sample ?w - waypoint)    ; Sample ?s must be collected at waypoint ?w
    )

    ; ---------------------------------
    ; Actions
    ; ---------------------------------

    ; Activate rover at lander location
    (:action activate
        :parameters (?r - rover ?ld - lander ?w - waypoint)
        :precondition (and
            (lander-at ?ld ?w)    ; Rover must be at the same location as lander
            (not (activated ?r))  ; Rover must not already be activated
        )
        :effect (and
            (activated ?r)         ; Rover is now activated
            (positioned ?r ?w)     ; Rover is at waypoint ?w
            (idle ?r)              ; Rover memory is free to collect data
        )
    )

    ; Rover travels between two connected waypoints
    (:action travel
        :parameters (?r - rover ?from ?to - waypoint)
        :precondition (and
            (positioned ?r ?from) ; Rover must be at the starting waypoint
            (path ?from ?to)      ; There must be a path to the destination waypoint
        )
        :effect (and
            (not (positioned ?r ?from)) ; Rover leaves the starting waypoint
            (positioned ?r ?to)         ; Rover arrives at the destination
        )
    )

    ; Rover captures a photo at a photo site
    (:action capture-photo
        :parameters (?r - rover ?w - waypoint ?d - data)
        :precondition (and
            (positioned ?r ?w)   ; Rover is at the waypoint
            (idle ?r)            ; Rover memory is free
            (photo-site ?d ?w)   ; This waypoint has a photo site
        )
        :effect (and
            (carrying-data ?r ?d) ; Rover now carries the photo data
            (not (idle ?r))       ; Memory is no longer free
        )
    )

    ; Rover performs a scan at a scan site
    (:action perform-scan
        :parameters (?r - rover ?w - waypoint ?d - data)
        :precondition (and
            (positioned ?r ?w)   ; Rover is at the waypoint
            (idle ?r)            ; Rover memory is free
            (scan-site ?d ?w)    ; This waypoint has a scan site
        )
        :effect (and
            (carrying-data ?r ?d) ; Rover now carries the scan data
            (not (idle ?r))       ; Memory is no longer free
        )
    )

    ; Rover sends collected data to the lander
    (:action send-data
        :parameters (?r - rover ?ld - lander ?w - waypoint ?d - data)
        :precondition (and
            (positioned ?r ?w)       ; Rover is at some waypoint
            (carrying-data ?r ?d)    ; Rover must be carrying data ?d
            (exists (?w2 - waypoint) (lander-at ?ld ?w2)) ; Lander exists somewhere
        )
        :effect (and
            (data-sent ?d ?ld)        ; Data is sent to lander
            (idle ?r)                 ; Rover memory becomes free
            (not (carrying-data ?r ?d)) ; Rover no longer carries the data
        )
    )

    ; Rover collects a sample at a sample site
    (:action gather-sample
        :parameters (?r - rover ?w - waypoint ?s - sample)
        :precondition (and
            (positioned ?r ?w)     ; Rover is at the sample location
            (sample-site ?s ?w)    ; Sample ?s is available at this waypoint
        )
        :effect (and
            (holding-sample ?r ?s) ; Rover now holds the sample
        )
    )

    ; Rover deposits sample to the lander
    (:action deposit-sample
        :parameters (?r - rover ?ld - lander ?w - waypoint ?s - sample)
        :precondition (and
            (holding-sample ?r ?s)            ; Rover is holding the sample
            (positioned ?r ?w)                 ; Rover is at the lander's location
            (lander-at ?ld ?w)                 ; Lander is at this waypoint
            (not (exists (?s2 - sample) (stored-sample ?ld ?s2))) ; Lander has free storage
        )
        :effect (and
            (stored-sample ?ld ?s)             ; Sample is now stored in lander
            (not (holding-sample ?r ?s))       ; Rover no longer holds the sample
        )
    )
)
