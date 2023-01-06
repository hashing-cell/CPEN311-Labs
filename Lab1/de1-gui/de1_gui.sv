module de1_gui(output logic [9:0] SW, output logic [3:0] KEY, input logic [9:0] LEDR, input logic [6:0] HEX5, input logic [6:0] HEX4, input logic [6:0] HEX3, input logic [6:0] HEX2, input logic [6:0] HEX1, input logic [6:0] HEX0);
    // de1_gui_ifc_* must be synchronized with GUI Tcl
    logic de1_gui_ifc_key3, de1_gui_ifc_key2, de1_gui_ifc_key1, de1_gui_ifc_key0;
    logic de1_gui_ifc_sw9, de1_gui_ifc_sw8, de1_gui_ifc_sw7, de1_gui_ifc_sw6, de1_gui_ifc_sw5, de1_gui_ifc_sw4, de1_gui_ifc_sw3, de1_gui_ifc_sw2, de1_gui_ifc_sw1, de1_gui_ifc_sw0;
    assign SW = {de1_gui_ifc_sw9, de1_gui_ifc_sw8, de1_gui_ifc_sw7, de1_gui_ifc_sw6, de1_gui_ifc_sw5, de1_gui_ifc_sw4, de1_gui_ifc_sw3, de1_gui_ifc_sw2, de1_gui_ifc_sw1, de1_gui_ifc_sw0};
    assign KEY = {~de1_gui_ifc_key3, ~de1_gui_ifc_key2, ~de1_gui_ifc_key1, ~de1_gui_ifc_key0};
    generate
        genvar i;
        for (i = 0; i < 10; i = i + 1) begin: leds
            always_comb mti_fli::mti_Command($sformatf("::de1::led_set %d %d", i, LEDR[i]));
        end: leds
    endgenerate
    generate
        genvar seg;
        for (seg = 0; seg < 7; seg = seg + 1) begin: hexs
            always_comb mti_fli::mti_Command($sformatf("::de1::hex_set 0 %d %d", seg, ~HEX0[seg]));
            always_comb mti_fli::mti_Command($sformatf("::de1::hex_set 1 %d %d", seg, ~HEX1[seg]));
            always_comb mti_fli::mti_Command($sformatf("::de1::hex_set 2 %d %d", seg, ~HEX2[seg]));
            always_comb mti_fli::mti_Command($sformatf("::de1::hex_set 3 %d %d", seg, ~HEX3[seg]));
            always_comb mti_fli::mti_Command($sformatf("::de1::hex_set 4 %d %d", seg, ~HEX4[seg]));
            always_comb mti_fli::mti_Command($sformatf("::de1::hex_set 5 %d %d", seg, ~HEX5[seg]));
        end: hexs
    endgenerate
    initial mti_fli::mti_Command("::de1::init");
endmodule: de1_gui
