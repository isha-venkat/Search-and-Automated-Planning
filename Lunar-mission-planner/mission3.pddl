(define (problem lunar-mission-3)
    (:domain lunar-extended)

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

        ; Astronauts
        alice bob - astronaut

        ; Lander areas
        lander1_control_room lander1_docking_bay - lander-area
        lander2_control_room lander2_docking_bay - lander-area
    )

    (:init
        ; -------------------------------
        ; Lander and Rover positions
        ; -------------------------------
        (lander-at lander1 waypoint2)             ; Lander 1 at waypoint 2
        (lander-at lander2 waypoint5)             ; Lander 2 at waypoint 5
        (activated rover1)                        ; Rover 1 already activated
        (positioned rover1 waypoint2)             ; Rover 1 at waypoint 2
        (idle rover1)                             ; Rover 1 memory free
        (not (activated rover2))                  ; Rover 2 not yet activated

        ; -------------------------------
        ; Waypoint connections (bidirectional)
        ; -------------------------------
        (path waypoint1 waypoint2)
        (path waypoint2 waypoint1)
        (path waypoint2 waypoint4)
        (path waypoint4 waypoint2)
        (path waypoint3 waypoint5)
        (path waypoint5 waypoint3)
        (path waypoint2 waypoint3)
        (path waypoint5 waypoint6)
        (path waypoint6 waypoint4)

        ; -------------------------------
        ; Data and sample locations
        ; -------------------------------
        (photo-site image2 waypoint2)             ; Image 2 to be captured at waypoint 2
        (photo-site image3 waypoint3)             ; Image 3 at waypoint 3
        (scan-site scan4 waypoint4)               ; Scan 4 at waypoint 4
        (scan-site scan6 waypoint6)               ; Scan 6 at waypoint 6
        (sample-site sample1 waypoint1)           ; Sample 1 at waypoint 1
        (sample-site sample5 waypoint5)           ; Sample 5 at waypoint 5

        ; -------------------------------
        ; Lander 1 area definitions
        ; -------------------------------
        (area-of lander1_control_room lander1)
        (area-of lander1_docking_bay lander1)
        (control-room lander1_control_room)      ; Control room marker
        (docking-bay lander1_docking_bay)        ; Docking bay marker

        ; -------------------------------
        ; Lander 2 area definitions
        ; -------------------------------
        (area-of lander2_control_room lander2)
        (area-of lander2_docking_bay lander2)
        (control-room lander2_control_room)
        (docking-bay lander2_docking_bay)

        ; -------------------------------
        ; Initial astronaut positions
        ; -------------------------------
        (crew-located alice lander1_docking_bay) ; Alice starts in Lander 1 docking bay
        (crew-located bob lander2_control_room)  ; Bob starts in Lander 2 control room
    )

    (:goal
        (and
            ; -------------------------------
            ; Data delivery goals
            ; -------------------------------
            (data-sent image2 lander1)               ; Image 2 sent to Lander 1
            (data-sent image3 lander1)               ; Image 3 sent to Lander 1
            (data-sent scan4 lander2)                ; Scan 4 sent to Lander 2
            (data-sent scan6 lander2)                ; Scan 6 sent to Lander 2

            ; -------------------------------
            ; Sample storage goals
            ; -------------------------------
            (stored-sample lander1 sample1)          ; Sample 1 stored in Lander 1
            (stored-sample lander2 sample5)          ; Sample 5 stored in Lander 2
        )
    )
)