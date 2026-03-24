(define (domain lunar-extended)
    (:requirements :strips :typing)  

    ; ---------------------------------
    ; Types
    ; ---------------------------------
    (:types
        lander           ; Spacecraft on lunar surface
        rover            ; Mobile robot to explore and collect data
        waypoint         ; Points on the lunar surface for rover navigation
        sample           ; Lunar rock/soil samples to collect
        data             ; Scientific data (images, scans)
        astronaut        ; Crew members operating rovers/landers
        lander-area      ; Specific areas inside a lander (control room, docking bay, etc.)
    )

    ; ---------------------------------
    ; Predicates
    ; ---------------------------------
    (:predicates
        ; Rover / lander location predicates
        (positioned ?r - rover ?w - waypoint)       ; Rover ?r is currently at waypoint ?w
        (lander-at ?ld - lander ?w - waypoint)      ; Lander ?ld is at waypoint ?w
        (path ?w1 - waypoint ?w2 - waypoint)       ; There is a path connecting waypoint ?w1 to ?w2

        ; Rover status predicates
        (activated ?r - rover)                      ; Rover has been activated
        (idle ?r - rover)                           ; Rover has free memory (not carrying data)
        (carrying-data ?r - rover ?d - data)       ; Rover is carrying data ?d
        (data-sent ?d - data ?ld - lander)         ; Data ?d has been sent to lander
        (holding-sample ?r - rover ?s - sample)    ; Rover is holding sample ?s
        (stored-sample ?ld - lander ?s - sample)   ; Sample ?s stored in lander

        ; Data / sample collection locations
        (photo-site ?d - data ?w - waypoint)       ; Photo data ?d must be collected at waypoint ?w
        (scan-site ?d - data ?w - waypoint)        ; Scan data ?d must be collected at waypoint ?w
        (sample-site ?s - sample ?w - waypoint)    ; Sample ?s must be collected at waypoint ?w

        ; Astronaut / lander area management predicates
        (crew-located ?a - astronaut ?la - lander-area) ; Astronaut ?a is in a specific lander area
        (area-of ?la - lander-area ?ld - lander)       ; Area ?la is part of lander ?ld
        (control-room ?la - lander-area)               ; Area is designated as control room
        (docking-bay ?la - lander-area)                ; Area is designated as docking bay
    )

    ; ---------------------------------
    ; Actions
    ; ---------------------------------

    ; Astronaut moves between two areas inside the same lander
    (:action crew-move
        :parameters (?a - astronaut ?from ?to - lander-area ?ld - lander)
        :precondition (and
            (crew-located ?a ?from)   ; Astronaut must start in source area
            (area-of ?from ?ld)       ; Source area belongs to lander ?ld
            (area-of ?to ?ld)         ; Destination area belongs to same lander
        )
        :effect (and
            (crew-located ?a ?to)     ; Astronaut moves to destination area
            (not (crew-located ?a ?from)) ; Astronaut no longer in source area
        )
    )

    ; Activate rover with astronaut in docking bay
    (:action activate
        :parameters (?r - rover ?ld - lander ?w - waypoint ?a - astronaut ?bay - lander-area)
        :precondition (and
            (lander-at ?ld ?w)          ; Rover is at the lander’s waypoint
            (not (activated ?r))        ; Rover is not yet activated
            (crew-located ?a ?bay)      ; Astronaut must be in docking bay
            (area-of ?bay ?ld)          ; Docking bay belongs to this lander
            (docking-bay ?bay)          ; Ensure it is a docking bay
        )
        :effect (and
            (activated ?r)              ; Rover activated
            (positioned ?r ?w)          ; Rover positioned at lander
            (idle ?r)                   ; Rover memory ready for tasks
        )
    )

    ; Rover travels between connected waypoints
    (:action travel
        :parameters (?r - rover ?from ?to - waypoint)
        :precondition (and
            (positioned ?r ?from)      ; Rover starts at source waypoint
            (path ?from ?to)           ; A path exists to destination
        )
        :effect (and
            (not (positioned ?r ?from)) ; Rover leaves source waypoint
            (positioned ?r ?to)         ; Rover arrives at destination waypoint
        )
    )

    ; Rover captures photo at a designated photo site
    (:action capture-photo
        :parameters (?r - rover ?w - waypoint ?d - data)
        :precondition (and
            (positioned ?r ?w)          ; Rover at waypoint
            (idle ?r)                   ; Memory free
            (photo-site ?d ?w)          ; Photo must be collected here
        )
        :effect (and
            (carrying-data ?r ?d)       ; Rover carries photo data
            (not (idle ?r))             ; Memory now occupied
        )
    )

    ; Rover performs scan at a designated scan site
    (:action perform-scan
        :parameters (?r - rover ?w - waypoint ?d - data)
        :precondition (and
            (positioned ?r ?w)
            (idle ?r)
            (scan-site ?d ?w)
        )
        :effect (and
            (carrying-data ?r ?d)
            (not (idle ?r))
        )
    )

    ; Rover sends collected data to lander with astronaut in control room
    (:action send-data
        :parameters (?r - rover ?ld - lander ?w - waypoint ?d - data ?a - astronaut ?ctrl - lander-area)
        :precondition (and
            (positioned ?r ?w)
            (carrying-data ?r ?d)
            (exists (?w2 - waypoint) (lander-at ?ld ?w2)) ; Lander exists
            (crew-located ?a ?ctrl)                        ; Astronaut present
            (area-of ?ctrl ?ld)			; Control room belongs to this lander
            (control-room ?ctrl)                           ;  Ensure it is a control room
        )
        :effect (and
            (data-sent ?d ?ld)       ; Data successfully sent
            (idle ?r)                ; Memory freed
            (not (carrying-data ?r ?d))
        )
    )

    ; Rover gathers sample at a sample site
    (:action gather-sample
        :parameters (?r - rover ?w - waypoint ?s - sample)
        :precondition (and
            (positioned ?r ?w)
            (sample-site ?s ?w)
        )
        :effect (and
            (holding-sample ?r ?s)
        )
    )

    ; Rover deposits sample to lander with astronaut in docking bay
    (:action deposit-sample
        :parameters (?r - rover ?ld - lander ?w - waypoint ?s - sample ?a - astronaut ?bay - lander-area)
        :precondition (and
            (holding-sample ?r ?s)      ; Rover holds sample
            (positioned ?r ?w)          ; Rover at lander waypoint
            (lander-at ?ld ?w)          ; Lander present
            (not (exists (?s2 - sample) (stored-sample ?ld ?s2))) ; Lander has space
            (crew-located ?a ?bay)      ; Astronaut present
            (area-of ?bay ?ld)		 ; Docking bay belongs to this lander
            (docking-bay ?bay)		; Ensure it is a docking bay
        )
        :effect (and
            (stored-sample ?ld ?s)      ; Sample stored in lander
            (not (holding-sample ?r ?s))
        )
    )
)