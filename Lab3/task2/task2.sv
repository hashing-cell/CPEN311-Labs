module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    /* Registers setup */ 
    logic[23:0] key;
    assign key[23:10] = 14'd0;
    assign key[9:0] = SW[9:0];

    logic rdy_s, rdy_k, en_s, en_k, wren_s, wren_k, s_wren, s_data, s_addr;
    logic [7:0] addr_s, addr_k, data_s, data_k, q;

    /* Statemachine for task2 */
    enum{INIT, S_RDY1, S_RDY2, S_RDY3, S_PHASE, K_RDY1, K_RDY2, K_RDY3, K_PHASE, DONE} state;

    always @(posedge CLOCK_50) begin
        if(~KEY[3]) begin
            state <= INIT;
        end else begin
            /*State at INIT */
            if(state == INIT) begin
                en_s <= 1'b0;
                en_k <= 1'b0;

                state <= (rdy_s) ? S_RDY1 : INIT;
            end

            /*State at S_RDY1 */
            else if(state == S_RDY1) begin
                en_s <= 1'b1;
                state <= S_RDY2;
            end

            /*State at S_RDY2 */
            else if(state == S_RDY2) begin
                en_s <= 1'b0;

                state <= S_RDY3;
            end

            /*State at S_RDY3 */
            else if(state == S_RDY3) begin
                en_s <= 1'b0;

                /* Redirect memory for init module */
                s_data <= 0; 
                s_addr <= 0; 
                s_wren <= 0; 

                state <= S_PHASE;
            end

            /*State at S_PHASE */
            else if(state == S_PHASE) begin
                state <= (rdy_s) ? K_RDY1 : S_PHASE;
            end

            /*State at K_RDY1 */
            else if(state == K_RDY1) begin
                en_k = 1'b1;
                state <= K_RDY2;
            end

            /*State at K_RDY2 */
            else if(state == K_RDY2) begin
                en_k = 1'b0;

                state <= K_RDY3;
            end

            /*State at K_RDY3 */
            else if(state == K_RDY3) begin
                en_s <= 1'b0;

                /* Redirect memory for ksa module */
                s_data <= 1; 
                s_addr <= 1; 
                s_wren <= 1; 

                state <= K_PHASE;
            end
            
            /*State at K_PHASE */
            else if(state == K_PHASE) begin
                state <= (rdy_k) ? DONE : K_PHASE;
            end

            /*State at DONE */
            else if(state == DONE) begin
                state <= DONE;
            end
            
        end
    end
    

    /* Instantiate init module from task 1 */
    init S_phase (  .clk(CLOCK_50), 
                    .rst_n(KEY[3]),
                    .en(en_s), 
                    .rdy(rdy_s),
                    .addr(addr_s), 
                    .wrdata(data_s), 
                    .wren(wren_s));

    /* Instantiate ksa module form task 2 */
    ksa K_phase (   .clk(CLOCK_50), 
                    .rst_n(KEY[3]),
                    .en(en_k), 
                    .rdy(rdy_k),
                    .key(key),
                    .addr(addr_k), 
                    .rddata(q), 
                    .wrdata(data_k), 
                    .wren(wren_k));
    /* Instantiate memory from Wizard */
    s_mem s (       .address((s_addr) ? addr_k : addr_s), 
                    .clock(CLOCK_50), 
                    .data((s_data) ? data_k : data_s), 
                    .wren((s_wren) ? wren_k : wren_s), 
                    .q(q));

endmodule: task2
