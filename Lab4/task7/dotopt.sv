module dotopt(input logic clk, input logic rst_n,
           // slave (CPU-facing)
           output logic slave_waitrequest,
           input logic [3:0] slave_address,
           input logic slave_read, output logic [31:0] slave_readdata,
           input logic slave_write, input logic [31:0] slave_writedata,

           // master_* (SDRAM-facing): weights (anb biases for task7)
           input logic master_waitrequest,
           output logic [31:0] master_address,
           output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
           output logic master_write, output logic [31:0] master_writedata,

           // master2_* (SRAM-facing to bank0 and bank1): input activations (and output activations for task7)
           input logic master2_waitrequest,
           output logic [31:0] master2_address,
           output logic master2_read, input logic [31:0] master2_readdata, input logic master2_readdatavalid,
           output logic master2_write, output logic [31:0] master2_writedata);

    // your code: you may wish to start by copying code from your "dot" module, and then add control for master2_* port

    logic        slave_write_addr0;
    logic signed [63:0] w_temp_times_a_temp;
    logic signed [31:0] w_temp_times_a_temp_32;
    logic [31:0] in_data;
    logic [31:0] in_data2;


    logic [31:0] w_addr_start;
    logic [31:0] a_addr_start;
    logic [31:0] n_in;

    logic [31:0] w_addr;
    logic [31:0] a_addr;
    logic [31:0] i;
    logic [31:0] debug_addr;

    logic signed [31:0] w_temp;
    logic signed [63:0] w_temp_64;
    logic signed [31:0] w_nxt;
    logic signed [31:0] a_temp;
    logic signed [63:0] a_temp_64;
    logic signed [31:0] a_nxt;
    logic signed [31:0] sum;
    logic signed [31:0] sum_nxt;

    logic received_master2_readdatavalid;
    logic received_master2_readdatavalid_rst;
    logic received_master2_waitrequest;
    logic received_master2_waitrequest_rst;

    assign w_temp_64 = w_temp;
    assign a_temp_64 = a_temp;

    typedef enum {
        NONE,
        RESTART,
        INCRE
    } ctrl_t;
    ctrl_t w_addr_ctrl, a_addr_ctrl, i_ctrl;


    typedef enum{
        READY = '0,
        INIT,
        CHECK_i,
        RD_Wi,
        WAIT_RD_Wi,
        WAIT_RD_Wi2,
        RD_Ai,
        WAIT_RD_Ai,
        WAIT_RD_Ai2,
        COMPUTE,
        WR_RESULT,
        WAIT_WR_RESULT
    } state_t;
    state_t curr_state, next_state;

    // FSM State Register
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            curr_state <= READY;
        end
        else begin
            curr_state <= next_state;
        end
    end

    // FSM Next State Logic
    always_comb begin
        case (curr_state)
        INIT: begin
            next_state = CHECK_i;
        end
        CHECK_i: begin
            next_state = (i >= n_in) ? READY : RD_Wi;
        end
        RD_Wi: begin
            next_state = (~master_waitrequest & (received_master2_waitrequest | ~master2_waitrequest)) ? WAIT_RD_Wi : RD_Wi;
        end
        WAIT_RD_Wi: begin
            next_state = (master_readdatavalid & (received_master2_readdatavalid | master2_readdatavalid)) ? COMPUTE : WAIT_RD_Wi;
        end
        COMPUTE: begin
            next_state = CHECK_i;
        end
        WR_RESULT: begin
            next_state = ~master_waitrequest ? WAIT_WR_RESULT : WR_RESULT;
        end
        WAIT_WR_RESULT: begin
            next_state = CHECK_i;
        end
        default: begin
            next_state = slave_write_addr0 ? INIT : READY;
        end
        endcase
    end

    // FSM Output Logic
    always_comb begin
        slave_waitrequest = slave_read & (slave_address == 0);
        master_address   = '0;
        master_read      = 1'b0;
        master_write     = 1'b0;
        master_writedata = '0;

        master2_address   = '0;
        master2_read      = 1'b0;
        master2_write     = 1'b0;
        master2_writedata = '0;

        received_master2_readdatavalid_rst = 1'b0;
        received_master2_waitrequest_rst   = 1'b0;
        
        w_addr_ctrl = NONE;
        a_addr_ctrl = NONE;
        i_ctrl      = NONE;

        sum_nxt = sum;

        case (curr_state)
        INIT: begin
            sum_nxt = '0;
        end
        CHECK_i: begin
            //
        end
        RD_Wi: begin
            master_read                        = 1'b1;
            master_address                     = w_addr;
            master2_read                       = 1'b1;
            master2_address                    = a_addr;
            received_master2_readdatavalid_rst = 1'b1;
            received_master2_waitrequest_rst   = 1'b1;
        end
        WAIT_RD_Wi: begin
            //
        end
        COMPUTE: begin
            sum_nxt     = sum + w_temp_times_a_temp_32;
            w_addr_ctrl = INCRE;
            a_addr_ctrl = INCRE;
            i_ctrl      = INCRE;
        end
        WR_RESULT: begin
            master_write     = 1'b1;
            master_address   = debug_addr;
            master_writedata = sum;
        end
        WAIT_WR_RESULT: begin
            //
        end
        default: begin
            slave_waitrequest = 1'b0;
            i_ctrl            = RESTART;
            w_addr_ctrl       = RESTART;
            a_addr_ctrl       = RESTART;
        end
        endcase
    end
    

    // w_addr register
    always_ff @(posedge clk) begin
        if (!rst_n || w_addr_ctrl == RESTART) begin
            w_addr     <= w_addr_start;
            debug_addr <= 32'h9000;
        end else if (w_addr_ctrl == INCRE) begin
            w_addr     <= w_addr + 32'd4;
            debug_addr <= debug_addr + 32'd4;
        end
    end

    // a_addr register
    always_ff @(posedge clk) begin
        if (!rst_n || a_addr_ctrl == RESTART) begin
            a_addr <= a_addr_start;
        end else if (w_addr_ctrl == INCRE) begin
            a_addr <= a_addr + 32'd4;
        end
    end

    // i register
    always_ff @(posedge clk) begin
        if (!rst_n || i_ctrl == RESTART) begin
            i <= 32'd0;
        end else if (i_ctrl == INCRE) begin
            i <= i + 32'd1;
        end
    end

    // registers
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sum    <= '0;
        end else begin
            sum    <= sum_nxt;
        end
    end

    // register to store data from input readdata (w)
    always_ff @(posedge clk) begin
        if (master_readdatavalid) begin
            w_temp <= master_readdata;
        end
    end

    // register to store data from input readdata (a)
    always_ff @(posedge clk) begin
        if (master2_readdatavalid) begin
            a_temp <= master2_readdata;
        end
    end

    // remember when we're done waiting for a to be read
    always_ff @(posedge clk) begin
        if (!rst_n || received_master2_waitrequest_rst) begin
            received_master2_waitrequest <= 1'b0;
        end else if (~master2_waitrequest) begin
            received_master2_waitrequest <= 1'b1;
        end
    end

    // remember when we got the a that was read
    always_ff @(posedge clk) begin
        if (!rst_n || received_master2_readdatavalid_rst) begin
            received_master2_readdatavalid <= 1'b0;
        end else if (master2_readdatavalid) begin
            received_master2_readdatavalid <= 1'b1;
        end
    end

    assign slave_write_addr0      = (slave_address == 0) & slave_write;
    assign w_temp_times_a_temp    = w_temp_64 * a_temp_64; // 64-bit wide
    assign w_temp_times_a_temp_32 = {w_temp_times_a_temp[63], w_temp_times_a_temp[46:16]};


    logic [31:0] mem [0:15];
    ///////////////////////////////////////////////////////////////////////////////
    // Inferred synchronous single-port RAM with common read and write addresses //
    ///////////////////////////////////////////////////////////////////////////////
    assign w_addr_start = mem[4'd2];
    assign a_addr_start = mem[4'd3];
    assign n_in = mem[4'd5];
    always @(posedge clk)
    begin
        if (slave_write) begin
            mem[slave_address] <= slave_writedata;
        end
    end

    assign slave_readdata = (slave_read & slave_address != '0) ? mem[slave_address] : sum;

endmodule: dotopt
