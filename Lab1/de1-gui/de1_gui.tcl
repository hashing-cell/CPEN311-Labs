# vim: set sw=4 ai cin et:

# NOTE: all UI elements are active-high (unlike the actual DE1-SoC)
# NOTE: de1_gui_ifc_* names must be sychronized with SystemVerilog GUI connector module

package require tooltip

if { [namespace exists ::de1] } { namespace delete ::de1 }

namespace eval ::de1 {
    namespace eval var {
        variable sw
        array set sw { 0 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 }
        variable sw_ref
        array set sw_ref { 0 {} 1 {} 2 {} 3 {} 4 {} 5 {} 6 {} 7 {} 8 {} 9 {} }
        variable key
        array set key { 0 0 1 0 2 0 3 0 }
        variable key_ref
        array set key_ref { 0 {} 1 {} 2 {} 3 {} }
        variable led
        array set led { 0 z 1 z 2 z 3 z 4 z 5 z 6 z 7 z 8 z 9 z }
        variable hex
        array set hex { 0,0 0 0,1 0 0,2 0 0,3 0 0,4 0 0,5 0 0,6 0 1,0 0 1,1 0 1,2 0 1,3 0 1,4 0 1,5 0 1,6 0 2,0 0 2,1 0 2,2 0 2,3 0 2,4 0 2,5 0 2,6 0 3,0 0 3,1 0 3,2 0 3,3 0 3,4 0 3,5 0 3,6 0 4,0 0 4,1 0 4,2 0 4,3 0 4,4 0 4,5 0 4,6 0 5,0 0 5,1 0 5,2 0 5,3 0 5,4 0 5,5 0 5,6 0 }
    }
    image create photo de1_sw_0 -data "R0lGODlhFAAvAPZ6AAAAAAMDAwQEBAUFBQgICA0NCg8PDRAQDRUWExYXFBkZFxkaFxoaGBsbGRwcGh0dGx8fGx8gHCAhHSEiHSEiHiIiHiIjHiIjHyMjHyMkHyQkICQlICUlIyUmICUmISUnISYnIicnJCcnJScoIycoJCgpJCgpJSkpJykqJSkqJiorJyssJysrKS0tKy0uKS0uKi4uKi4vKy4uLDAxLDAxLTAwLjExLzIyMDc3NTg4Njk5Nz8/PT1FQ0BAPUBAPkBAP0FBP0hIRkpKSEpKSU1NS09PTVNTUlRUVFdXV1ddW19fXmJiYWJjYWNlZGRlYmRlY2VlY2RlZWVmZGZmZGdnZ2doZ2pqaGtra2tsamxsa2xsbGxtbW1tbW1ubW5ubnFxcXBycXJycnJzc3Nzc3Z2dHh4dnh4d3t8eoeHh4iIh4mJiI2NjY6OjpCQkJGRkZKSkpOTk5SUlJWVlZWWlpaWlpiYmJmZmZqampqam5ubm////wAAAAAAAAAAAAAAAAAAACH5BAEAAHoALAAAAAAUAC8AAAf+gDxgbXF0dHF2hYaKh4ZwTVpwdpOUlZZ2dJCIlnV2nZeZkZx1pJeYkJKVpKurlHGol52ynpN5r6KqrLOTdFRabZy0rK5NXHCfk6WypbzFqZ66yZV0UFfHubSg1dd53d7feZTUXG+TaF9fYOrrYGFrvFDGdnlIAQMCAgP6+gRe3XHx3Mw7EgCAwYMGA2gJFyfKFYF5jiCcKGChJyhZJOVRkmBBgo8gO45hiFHjlAwZRqQcoXIECjPh6jTJOO9kS5UrXzKcaTIDipYpUY6AeUoLojwnha5M+XLSraM2UQTNwMEnTFuaavpM+eKFi682yMQZy1MryhU9fKhVO4SIk0f+kejkgVIVpYO7eB0oCHILTjcoGSykjCFDho3CMlgMaUPF2jwogjmMYLGChWXLJxY7e2wBxAgOIUaEGD2aw5A4Tqx1czIBRAYVNmzcmH3DRg0ibZpYkwsZRFUHDYIL3xunsd88rH2vyMG8OfMibbbx7jzCwQED2A9oL6AjOhc3deZCCKFhQoXzEyxUgHCCy7hjdaBo0GCBg+SlLLjUAUguPBQIFNiH0oAZNAGPMeFZwUINLsQwg4MzzEDDGeFQc0U5driBBhppdOhhh5vQ4dAzeFASTjjziOOQQKa0KOKFLboYD3ytxJjIjNHYaCGNzMT4ol+roOgjFFqwEQccSMIvMdaSTI4FRxRaRMkFF15QqYUXWmQRJZZRiqHFFVFEAcWYVDTRBBVQmHlmmE0kEQgAOw=="
    image create photo de1_sw_1 -data "R0lGODlhFAAvAPZmAAAAAAMDAw4ODg8PDw8QDBESDhESDxISEBMTERISEhMUEBYWFBkZFxoaGBsbGRwcGh8fHR8gGyAgHiEhHiEiHSEiHiMkHyQlICUmISYnIiYnIygpJCkqJSsrKSwsKjAwLjExLzQ0MjU2MjY2MzY2NDc3NTg4Njk5Njk5Nzo6ODw8OTw9OT09Oj09Oz1FQ0dHRUhIRlRUVFddW1tbW11dXGNlZGVlY2VmY2RlZWVmZGZmZGdnZWdnZ2doZ2tra2xta2xsbGxtbW1tbW1ubXFxcXBycXJycnJzc3R0cnh4dnh4d3x8e319fH9/fn9/f4KCgoODg4SEhIaHhoeHh4iIiImJiYqKioyMi46Ojo+Pj5CQkJGRkZGSkZKSkpOTk5SUlJWWlpaWlpiYmJmZmZqampubm////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAGYALAAAAAAUAC8AAAf+gC5FWl9hYV9jhoqKhWFeNUBeY5OUiWRkYWKUYmGQiJVioaKiY5yQkqCjo5idQJ+bqqutqLCxoYaQWpWltqWJO0C6qbKhiadkqmRjysyYxpHIomRUS03W101RXjg+XqtRLRPi4xMQIVTc3mKX4BkkJvDxJi/o3ZpXSC0VFg8N/f4NGnygUqPbsh0XLmTg8E6eCRL0Ckoic2NChgz8Amp8wGDgDnsUK1zkYAKFSZMnTtCzYZCMDZEXyU2oIO5cunUvL2bo4IGnh54dWtTz5hJmBQUFkiol8KHKjW6Xcl6AqTNDBRJMwqRbZmMmVZ0WsGLa6hJCBQwYEl60kOEHq6ftE3dUqDCVrgULIpVc0tryBoaqVTkkQcZ34o0LGgDrHMwJ7rLDfxULJkz2sGKMkzlVVng5cxjHFDlfZsy3y0HRgD1zMx368kK9jVvucP2aVbpLNBToTrAbgYIFR5SVXhYDgPHjxwMMEb76UnHkyAP4YO6jy7oZA7Jr154g+Jgvq0NlefIEShQo5tFDQVUa2aVLy5a9n6TZ3ij6xXaBrx4tP6ldhZEi4H2aBBgLfr6UYqAmCcJCSSctTaLMLgB+hIUXX2SIoYYbZviFF1704IMPQgAxxIlDmJiiiioe4UMPPeAg44wz1oCDjTLWMEMgADs="
    image create photo de1_led_v_0 -data "R0lGODlhBgALAPQVALq1jLq2jLq2jbu3jbu3jry4jry4j725j725kL66kcfFos7NsM7OsM/OsNTTuNvcxd/hzN/hze3x5u3y5+7y6P///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAABUALAAAAAAGAAsAAAUfoCSOTrOcSkEQAEAcayyvw6y6qyoffB/9EciDQiyGAAA7"
    image create photo de1_led_v_1 -data "R0lGODlhBgALAPQZAP8iAP8lAP8mAP8mAf8oAv8oA/8qBf8rB/4tCP4tCf4yDvpYOfh1Wvh2W/h2XPaJcvOolPK4p/K5p/K6qOzx5uzy5+zz6Oz06uz27P///wAAAAAAAAAAAAAAAAAAAAAAACH5BAEAABkALAAAAAAGAAsAAAUkoEWN4+M06GIALCAcQiwUhjzDcoHHul0oiWAwQiRCLBaMEhMCADs="
    image create photo de1_led_v_z -data "R0lGODlhBgALAPQZAK9oULBoULBqUrFqUrFrU7JqUrJrU7RrU7RsVLRtVLRuVrRvV7ZwWMGKdcmfi8mfjNCrmNm/r93Ku93LvN3Lve3x5u3y5+7z6O706v///wAAAAAAAAAAAAAAAAAAAAAAACH5BAEAABkALAAAAAAGAAsAAAUioFWNI/Q4aHMQQEskRBzD8kHLN2HL8ZIwi5eEQpRILshkCAA7"
    image create photo de1_key_0 -data "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"
    image create photo de1_key_1 -data "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"
    image create photo de1_hex -data "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"
    image create photo de1_hex_0 -data "R0lGODlhIgA5APECAAAAAP8AAP///wAAACH5BAEAAAIALAAAAAAiADkAAAI7lI+py+0Po5y02ouz3rx7E4TiSIpUiZJVml6sir3BR9f2jef6zvf+DwwKh8Si8YhMKpfMpvMJjUqnlAIAOw=="
    image create photo de1_hex_1 -data "R0lGODlhIgA5APECAAAAAP8AAP///wAAACH5BAEAAAIALAAAAAAiADkAAAJDlI+py+0Po5y02ouz3rz77wUBeIgjaIpoeoYpya7vx7ZdLau5zeF0/JsFeT+S8YhMKpfMpvMJjUqn1Kr1is1qt9xuAQA7"
    image create photo de1_hex_2 -data "R0lGODlhIgA5APECAAAAAP8AAP///wAAACH5BAEAAAIALAAAAAAiADkAAAJFlI+py+0Po5y02ouz3rz7D4biSJbmiabqyrYuEwRjLId07d14foP6zvn5dEOarfcRJolLJM94jM2k05f1is1qt9yut1EAADs="
    image create photo de1_hex_3 -data "R0lGODlhIgA5APECAAAAAP8AAP///wAAACH5BAEAAAIALAAAAAAiADkAAAI7lI+py+0Po5y02ouz3rz7D4biSJbmiabqyrbuC8fyTNf2/QT6zgdaD9RhgsQK8eibIIu4pvMJjUqnigIAOw=="
    image create photo de1_hex_4 -data "R0lGODlhIgA5APECAAAAAP8AAP///wAAACH5BAEAAAIALAAAAAAiADkAAAJClI+py+0Po5y02ouz3rz7D4biSJbmiabqyrYuF8RjLId0/d0BqO+5zgP+aLZb0DgkJnEdYbLoK76m1Kr1is1qt58CADs="
    image create photo de1_hex_5 -data "R0lGODlhIgA5APECAAAAAP8AAP///wAAACH5BAEAAAIALAAAAAAiADkAAAJDlI+py+0Po5y02ouz3rz7D0rBGBojGZ7opwZg67LtO8tnqtK5ffNrV+PhYriS8YhMKpfMpvMJjUqn1Kr1is1qt9xIAQA7"
    image create photo de1_hex_6 -data "R0lGODlhIgA5APECAAAAAP8AAP///wAAACH5BAEAAAIALAAAAAAiADkAAAI7lI+py+0Po5y02ouz3rz7D4biSJbmiabqyjrBC8eBJtcvZudXbu88TPu1hsSi8YhMKpfMpvMJjUqnqQIAOw=="
    image create photo de1_play_0 -data "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"
    image create photo de1_play_1 -data "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"

    proc sw_init {} {
        set old_env [env]
        env /
        for { set id 0 } { $id < 10 } { incr id } {
            array set var::sw "$id 0"
            array set var::sw_ref "$id [find nets -recursive -internal -nofilter de1_gui_ifc_sw$id]"
            force $var::sw_ref($id) $var::sw($id)
            .de1.cv create image [expr 36 + (9 - $id) * 28] 138 -image de1_sw_0 -tags "de1_sw_$id"
            ::tooltip::tooltip .de1.cv -items "de1_sw_${id}" "SW${id}"
            .de1.cv bind de1_sw_$id <ButtonPress-1> [namespace code "sw_click $id"]
        }
        env $old_env
    }

    proc sw_click { id } {
        set var::sw($id) [expr ! $var::sw($id)]
        force $var::sw_ref($id) $var::sw($id)
        sw_redraw $id
    }

    proc sw_redraw { id } {
        if { $id >= 0 && $id < 10 } {
            .de1.cv itemconfigure de1_sw_$id -image de1_sw_$var::sw($id)
        } else {
            error "unknown SW #: $id"
        }
    }

    proc key_init {} {
        set old_env [env]
        env /
        for { set id 0 } { $id < 4 } { incr id } {
            array set var::key "$id 0"
            array set var::key_ref "$id [find nets -recursive -internal -nofilter de1_gui_ifc_key$id]"
            force $var::key_ref($id) $var::key($id)
            .de1.cv create image [expr 335 + (3 - $id) * 52] 140 -image de1_key_$var::key($id) -tags "de1_key_$id"
            ::tooltip::tooltip .de1.cv -items "de1_key_${id}" "KEY${id}"
            .de1.cv bind de1_key_$id <ButtonPress-1> [namespace code "key_click $id"]
        }
        env $old_env
    }

    proc key_click { id } {
        set var::key($id) [expr ! $var::key($id)]
        force $var::key_ref($id) $var::key($id)
        key_redraw $id
    }

    proc key_redraw { id } {
        if { $id >= 0 && $id < 4 } {
            .de1.cv itemconfigure de1_key_$id -image de1_key_$var::key($id)
        } else {
            error "unknown key #: $id"
        }
    }

    proc led_init {} {
        for { set id 0 } { $id < 10 } { incr id } {
            array set var::led "$id z"
            .de1.cv create image [expr 30 + (9 - $id) * 28] 94 -image de1_led_v_z -tags "de1_led_$id"
            ::tooltip::tooltip .de1.cv -items "led_${id}" "LEDR${id}"
        }
    }

    proc led_redraw { id } {
        if { $id >= 0 && $id < 10 } {
            .de1.cv itemconfigure de1_led_$id -image de1_led_v_$var::led($id)
        } else {
            error "bad LED #: $id"
        }
    }

    proc led_set { id state } {
        if !({[winfo exists .de1]}) {init}
        if { $id >= 0 && $id < 10 } {
            set state [string tolower $state]
            if { [string equal $state "x"] } { set state 0 }
            array set var::led "$id $state"
            led_redraw $id
        } else {
            error "bad LED #: $id"
        }
    }

    proc hex_init {} {
        for { set id 0 } { $id < 6 } { incr id } {
            for { set seg 0 } { $seg < 7 } { incr seg } {
                array set var::hex "$id,$seg 0"
            }
            set pos [expr 5 - $id]
            .de1.cv create image [expr 43 + $pos * 30 + $pos / 2 * 5] 45 -image de1_hex -tags "de1_hex_${id}"
            ::tooltip::tooltip .de1.cv -items "hex_${id}" "HEX${id}"
            for { set seg 0 } { $seg < 7 } { incr seg } {
                .de1.cv create image [expr 43 + $pos * 30 + $pos / 2 * 5] 45 -image de1_hex_$seg -tags "de1_hex_${id}_${seg}" -state hidden
                ::tooltip::tooltip .de1.cv -items "hex_${id}_${seg}" "HEX${id}"
            }
        }
    }

    proc hex_set { id seg state } {
        if !({[winfo exists .de1]}) {init}
        if { $id >= 0 && $id < 6 && $seg >= 0 && $seg < 7 } {
            set state [string tolower $state]
            if { [string equal $state "x"] || [string equal $state "z" ]} { set state 0 }
            if { $state >= 0 && $state < 128 } {
                array set var::hex "$id,$seg $state"
                hex_redraw $id $seg
            } else {
                error "bad state for HEX$id: $state"
            }
        } else {
            error "bad HEX segment: $id / $seg"
        }
    }

    proc hex_redraw { id seg } {
        if { $id >= 0 && $id < 6 && $seg >= 0 && $seg < 7 } {
            set state $var::hex($id,$seg)
            .de1.cv itemconfigure de1_hex_${id}_${seg} -state [if {$state} {lindex normal} {lindex hidden}]
        } else {
            error "bad HEX segment: $id / $seg"
        }
    }

    proc play_init {} {
        .de1.cv create image 481 40 -image de1_play_0 -tags "de1_play"
        ::tooltip::tooltip .de1.cv -items "de1_play" "Run"
        .de1.cv bind de1_play <ButtonPress-1> [namespace code "play_click 1"]
        .de1.cv bind de1_play <ButtonRelease-1> [namespace code "play_click 0"]
    }

    proc play_click { state } {
        .de1.cv itemconfigure de1_play -image de1_play_$state
        if { $state == 1 } { ::run }
    }

    proc init {} {
        if ({[winfo exists .de1]}) { destroy .de1 }
        toplevel .de1 -width 550 -height 173
        wm minsize .de1 550 173
        wm maxsize .de1 550 173
        wm title .de1 "fake DE1-SoC board"
        canvas .de1.cv -width 550 -height 173 -background #0f1d1b
        pack .de1.cv
        sw_init
        key_init
        led_init
        hex_init
        play_init
    }
}

namespace inscope ::de1 init
