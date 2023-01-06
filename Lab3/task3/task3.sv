module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    /* Registers Declearation */
    logic clk, rst_n, en, rdy, pt_wren;
    logic [23:0] key;
    logic [7:0] ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;
    enum {
        PRE_RUN,
        WAIT_RDY,
        RUNNING,
        DONE} state;

    /* Operation on key value */
    // assign key[23:10] = 14'd00011110010001;
    assign key[23:10] = 14'd0;
    assign key[9:0] = SW[9:0];

    /* State machine */
    always @(posedge CLOCK_50) begin
        if(~KEY[3]) begin
            state <= PRE_RUN;
            en <= 1'b1;
        end else if(state <= PRE_RUN) begin
            en <= 1'b0;
            state <= WAIT_RDY;
        end else if(state <= WAIT_RDY) begin
            state <= RUNNING;
        end else if(state <= RUNNING) begin 
            state <= (rdy) ? DONE : RUNNING;
        end else 
            state <= DONE;
    end

    /* Instantiate ct memory for read only */
    ct_mem ct(
                .address    (ct_addr),
                .clock      (CLOCK_50),
                .data       (8'd0),
                .wren       (1'b0),
                .q          (ct_rddata));

    /* Instantiate pt memory for read and write */
    pt_mem pt(
                .address    (pt_addr),
                .clock      (CLOCK_50),
                .data       (pt_wrdata),
                .wren       (pt_wren),
                .q          (pt_rddata));

    /* Instantiate arc4 module */
    arc4 a4(    .clk        (CLOCK_50), 
                .rst_n      (KEY[3]),
                .en         (en), 
                .rdy        (rdy),
                .key        (key),
                .ct_addr    (ct_addr), 
                .ct_rddata  (ct_rddata),
                .pt_addr    (pt_addr), 
                .pt_rddata  (pt_rddata), 
                .pt_wrdata  (pt_wrdata), 
                .pt_wren    (pt_wren));


endmodule: task3
