namespace eval vga {
    set zoom 4
    set width 160
    set height 120
    set bg "#808080"
    set count 0
}

proc vga::init {} {
    toplevel .vga -padx 5 -pady 5
    wm title .vga "fake VGA screen"

    frame .vga.draw
    pack .vga.draw -expand 1 -fill both

    frame .vga.status
    button .vga.status.reset -width 5 -relief ridge -text "reset" -command { vga::reset }
    label .vga.status.count_legend -text "  count:"
    label .vga.status.count_val -relief groove -width 10

    label .vga.status.drawn_legend -text "last:"
    label .vga.status.drawn_pos -relief groove -width 7
    label .vga.status.click_legend -text "  clicked:"
    label .vga.status.click_pos -relief groove -width 7
    label .vga.status.mouse_legend -text "  mouse:"
    label .vga.status.mouse_pos -relief groove -width 7
    pack .vga.status.reset .vga.status.count_legend .vga.status.count_val -side left
    pack .vga.status.mouse_pos .vga.status.mouse_legend .vga.status.click_pos .vga.status.click_legend \
         .vga.status.drawn_pos .vga.status.drawn_legend -side right
    pack .vga.status -side bottom -fill x
    .vga.status.drawn_pos configure -text "-,-"
    .vga.status.mouse_pos configure -text "-,-"
    .vga.status.click_pos configure -text "-,-"

    set w [expr $vga::width * $vga::zoom]
    set h [expr {$vga::height * $vga::zoom}]
    canvas .vga.draw.c -width $w -height $h -bg $vga::bg
    pack .vga.draw.c -expand 1 -fill both
    bind .vga.draw.c <Motion> { vga::show_mouse %x %y }
    bind .vga.draw.c <ButtonPress> { vga::show_click %x %y }
    bind .vga.draw.c <Leave> { .vga.status.mouse_pos configure -text "-,-" }
}

proc vga::reset {} {
    .vga.draw.c create rectangle 0 0 [expr $vga::width * $vga::zoom - 1] [expr $vga::height * $vga::zoom - 1] -outline $vga::bg -fill $vga::bg
    set vga::count 0
    .vga.status.count_val configure -text "$vga::count"
    .vga.status.drawn_pos configure -text "-,-"
}

proc vga::rgb_to_hex {c} {
    set b [expr ($c & 1) * 255]
    set g [expr (($c >> 1) & 1) * 255]
    set r [expr (($c >> 2) & 1) * 255]
    return [format "#%02x%02x%02x" $r $g $b]
}

proc vga::plot {x y c} {
    if {[expr $x < 0]} { return }
    if {[expr $x >= $vga::width]} { return }
    if {[expr $y < 0]} { return }
    if {[expr $y >= $vga::height]} { return }
    if !({[winfo exists .vga]}) {vga::init}
    set x0 [expr $x * $vga::zoom]
    set y0 [expr $y * $vga::zoom]
    set x1 [expr ($x+1) * $vga::zoom - 1]
    set y1 [expr ($y+1) * $vga::zoom - 1]
    set clr [vga::rgb_to_hex $c]
    .vga.draw.c create rectangle $x0 $y0 $x1 $y1 -outline $clr -fill $clr
    incr vga::count
    .vga.status.count_val configure -text "$vga::count"
    .vga.status.drawn_pos configure -text "$x,$y:$c"
}

proc vga::show_mouse {x0 y0} {
     set x [expr $x0 / $vga::zoom]
     set y [expr $y0 / $vga::zoom]
     .vga.status.mouse_pos configure -text "$x,$y"
}

proc vga::show_click {x0 y0} {
     set x [expr $x0 / $vga::zoom]
     set y [expr $y0 / $vga::zoom]
     .vga.status.click_pos configure -text "$x,$y"
}
