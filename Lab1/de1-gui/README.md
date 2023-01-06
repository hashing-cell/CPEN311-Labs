# A Virtual DE1-SoC Board

## Contents

* [Introduction](#introduction)
* [What's in the box?](#whats-in-the-box)
* [Setting up the simulation](#setting-up-the-simulation)
* [Simulating RTL](#simulating-rtl)
* [Simulation versus The Real Thing™](#simulation-versus-the-real-thing)
* [Simulating the post\-synthesis netlist](#simulating-the-post-synthesis-netlist)


## Introduction

The labs in this course are designed to be completed using a DE1-SoC FPGA board. However, you may not always have physical access to one.

We have developed a “virtual” DE1-SoC that emulates a portion of the functionality of the real board — for this lab, the buttons, LEDs, and seven-segment displays.


## What's in the box?

The virtual DE1-SoC consists of two parts:

- a Tcl file (`de1_gui.tcl`) that you need to load in ModelSim before simulation to implement the GUI, and
- a SystemVerilog file (`de1_gui.sv`) that you need to instantiate in your testbench to connect to the GUI from your design.

The directory also contains a simple synthesizable design you can use to test that you are using the virtual board correctly (`button_pusher.sv`) and a testbench that shows you how to connect that design to the GUI.

**Important:** If you are debugging your circuit using the GUI, **do not** copy these files to your task folder, but reference them directly from the `de1-gui` folder (“Reference from current location” when you add the file). The `de1_gui.sv` file does not work without the `de1_gui.tcl` interface and it is not synthesizable. If you submit the file with your tasks, the autograder will treat it as part of your submission, and mark your submission as failing to simulate or synthesize.

**Again, to use the Virtual DE1-SoC, do not copy the files into your task folders! Instead, reference them using relative filenames, e.g.
`../de1-gui/de1_gui.sv`**


## Setting up the simulation

Launch ModelSim and create your project as covered in the Tutorial. Add `button_pusher.sv`, `de1_gui.sv`, and `tb_de1_gui.sv` to the project. To prevent accidentally submitting these files for marking, add files by referencing them in the existing directory rather than copying to your working directory:

<p align="center"><img src="figures/add-file.png" width="30%" height="30%" title="Adding a file by reference"></p>

If you accidentally submit these files, the autograder will mark your design as failing to simulate and non-synthesizable.

Compile the entire design as usual, and load the compiled design by double-clicking on the `tb_de1_gui` in the _Library_ tab.

Next, load the `de1_gui.tcl` via _File&rarr;Load&rarr;Macro&nbsp;File..._ or by issuing the `source de1_gui.tcl` command in the Transcript frame. You should see a new window that shows the switches, buttons, LEDs, and 7-segment displays of the DE1-SoC board:

<p align="center"><img src="figures/de1-gui-loaded.png" width="50%" height="50%" title="DE1-SoC GUI"></p>

All switches and buttons are in the “off” position (i.e., the SW signals are all 0, and the KEY signals are all 1 as they are active-low). The LEDs are simulating the dimly-lit state they appear in when they are not driven on the real board.

The fast-forward button <img src="figures/ff_button.png" width="auto" height="14pt"> does the same thing as <img src="figures/modelsim_run_button.png" width="auto" height="14pt"> in ModelSim — it advances the simulation by the amount of time shown next to <img src="figures/modelsim_run_button.png" width="auto" height="14pt"> — but saves you the need to constantly switch window focus between the DE1-SoC GUI and ModelSim.

Move the switches and push the buttons to see what you can interact with. Note that unlike on the physical board, buttons stay pushed if you click on them to let you gradually advance the simulation without holding the mouse button; clicking the buttons again will release them. Because the hardware design is not being simulated yet, none of the LEDs or 7-segment displays will change state.


## Simulating RTL

Now it's time to combine the GUI with simulated hardware. Add the testbench signals to a waveform and simulate for 100ps.

<p align="center"><img src="figures/sim-before-reset.png" width="50%" height="50%" title="Starting the simulation"></p>

Next, reset your design. The `button_pusher` design uses `KEY0` as reset, so click `KEY0` to push it in, advance the simulation for 100ps, click `KEY0` again to release it, and advance for another 100ps:

<p align="center"><img src="figures/sim-after-reset.png" width="50%" height="50%" title="Simulator window after reset"></p>

You should see that the virtual board display has changed:

<p align="center"><img src="figures/de1-gui-after-reset.png" width="50%" height="50%" title="The DE1-SoC GUI after reset"></p>

Try out the various switches and buttons and watch the design react. Remember that you have to **manually advance the simulation** — otherwise the simulated hardware will not react to your GUI inputs.


## Simulation versus The Real Thing™

If you have a physical DE1-SoC, synthesize `button_pusher` (don't forget the pin assignment file!) and download it to your FPGA. You will see that the initial state of the simulation differs from the real board, which will in all likelihood have the seven-segment displays lit:

<p align="center"><img src="figures/real-board-before-reset.jpg" width="33%" height="33%" title="Real DE1-SoC"></p>

Once you reset the design using `KEY0`, the two should behave correspondingly.

Why is this happening? In your RTL simulation, several signals — in particular the `HEX0`...`HEX5` registers that drive the 7-segment display drivers — are _undefined_ (`'x`), and acquire logical 0 or 1 values only after reset. But in the real hardware, there is no such thing as undefined, so in the real hardware those registers will have some kind of logical value; most likely this is 0, which causes the 7-segment displays to light up (as they are active-low). While you cannot rely on this initialization in general, it explains the discrepancy between the simulation and the hardware.



## Simulating the post-synthesis netlist

Now synthesize your design using Quartus as described in the Tutorial and locate the `button_pusher.vo` file in the `simulation/modelsim` folder.

Create a new ModelSim project as described above, except that instead of the `button_pusher.sv` RTL file add the `button_pusher.vo` file you synthesized, and compile the design.

When you now start simulation, you will need to add both the `cyclonev_ver` and `altera_ver` libraries as described in the Tutorial.

<p align="center"><img src="figures/post-synthesis-sim-libraries.png" width="33%" height="33%" title="Libraries for post-synthesis simulation"></p>

After adding these libraries, select `work.tb_de1_gui` from the _Design_ tab and load the simulation.

Now after you advance the simulation for the first 100ps, you will see that it corresponds to the real DE1-SoC even before you reset the design:

<p align="center"><img src="figures/de1-gui-post-synthesis.png" width="50%" height="50%" title="DE1-SoC GUI"></p>

This is because you are now simulating the gate-level netlist generated by Quartus, and the libraries you included (which define the primitive FPGA components) are initialized like the FPGA.

In this course, we will evaluate both your RTL and post-simulation netlist, so you would be well advised to simulate both.
