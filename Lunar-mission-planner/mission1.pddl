(define (problem lunar-mission-1)
    (:domain lunar)

    (:objects
        ; Rover
        rover1 - rover

        ; Lander
        lander1 - lander

        ; Waypoints in the lunar surface
        waypoint1 waypoint2 waypoint3 waypoint4 waypoint5 - waypoint

        ; Data to be collected
        image5 scan3 - data

        ; Sample to be collected
        sample1 - sample
    )

    (:init
        ; -------------------------------
        ; Lander and Rover initial state
        ; -------------------------------
        (lander-at lander1 waypoint1)       ; Lander 1 is located at Waypoint 1
        (idle rover1)                       ; Rover 1 starts with free memory (not carrying any data)

        ; -------------------------------
        ; Waypoint connections (one-way)
        ; -------------------------------
        (path waypoint1 waypoint2)          ; Rover can travel from wp1 to wp2
        (path waypoint1 waypoint4)          ; Rover can travel from wp1 to wp4
        (path waypoint2 waypoint3)          ; Rover can travel from wp2 to wp3
        (path waypoint3 waypoint5)          ; Rover can travel from wp3 to wp5
        (path waypoint4 waypoint3)          ; Rover can travel from wp4 to wp3
        (path waypoint5 waypoint1)          ; Rover can travel from wp5 to wp1

        ; -------------------------------
        ; Data and sample locations
        ; -------------------------------
        (photo-site image5 waypoint5)       ; Image 5 is located at Waypoint 5
        (scan-site scan3 waypoint3)         ; Scan 3 is located at Waypoint 3
        (sample-site sample1 waypoint1)     ; Sample 1 is located at Waypoint 1
    )

    (:goal
        (and
            ; -------------------------------
            ; Data collection goals
            ; -------------------------------
            (data-sent image5 lander1)      ; Image from Waypoint 5 must be transmitted to Lander 1
            (data-sent scan3 lander1)       ; Scan from Waypoint 3 must be transmitted to Lander 1

            ; -------------------------------
            ; Sample collection goal
            ; -------------------------------
            (stored-sample lander1 sample1) ; Sample from Waypoint 1 must be stored in Lander 1
        )
    )
)