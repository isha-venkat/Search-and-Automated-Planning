(define (problem lunar-mission-2)
    (:domain lunar)

    (:objects
        ; Rovers
        rover1 rover2 - rover

        ; Landers
        lander1 lander2 - lander

        ; Waypoints
        waypoint1 waypoint2 waypoint3 waypoint4 waypoint5 waypoint6 - waypoint

        ; Data objects
        image2 image3 - data
        scan4 scan6 - data

        ; Sample objects
        sample1 sample5 - sample
    )

    (:init
        ; -------------------------------
        ; Lander and Rover positions
        ; -------------------------------
        (lander-at lander1 waypoint2)             ; Lander 1 is at Waypoint 2
        (positioned rover1 waypoint2)             ; Rover 1 already deployed at Waypoint 2
        (activated rover1)                        ; Rover 1 is active
        (idle rover1)                             ; Rover 1 memory is free

        (lander-at lander2 waypoint5)             ; Lander 2 at Waypoint 5
        (idle rover2)                             ; Rover 2 starts undeployed

        ; -------------------------------
        ; Waypoint connections (some bidirectional, some one-way)
        ; -------------------------------
        (path waypoint1 waypoint2)
        (path waypoint2 waypoint1)

        (path waypoint2 waypoint3)                ; One-way path from 2 to 3

        (path waypoint3 waypoint5)
        (path waypoint5 waypoint3)

        (path waypoint5 waypoint6)
        (path waypoint6 waypoint4)

        (path waypoint4 waypoint2)
        (path waypoint2 waypoint4)

        ; -------------------------------
        ; Data and sample locations
        ; -------------------------------
        (photo-site image3 waypoint3)             ; Image 3 at Waypoint 3
        (scan-site scan4 waypoint4)               ; Scan 4 at Waypoint 4
        (photo-site image2 waypoint2)             ; Image 2 at Waypoint 2
        (scan-site scan6 waypoint6)               ; Scan 6 at Waypoint 6
        (sample-site sample5 waypoint5)           ; Sample 5 at Waypoint 5
        (sample-site sample1 waypoint1)           ; Sample 1 at Waypoint 1
    )

    (:goal
        (and
            ; -------------------------------
            ; Data delivery goals
            ; -------------------------------
            (data-sent image3 lander1)             ; Send Image 3 to Lander 1
            (data-sent scan4 lander1)              ; Send Scan 4 to Lander 1
            (data-sent image2 lander1)             ; Send Image 2 to Lander 1
            (data-sent scan6 lander2)              ; Send Scan 6 to Lander 2

            ; -------------------------------
            ; Sample storage goals
            ; -------------------------------
            (stored-sample lander1 sample5)        ; Sample 5 stored in Lander 1
            (stored-sample lander2 sample1)        ; Sample 1 stored in Lander 2
        )
    )
)