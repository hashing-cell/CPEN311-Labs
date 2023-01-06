module wordcopy(input logic clk, input logic rst_n,
                // slave (CPU-facing)
                output logic slave_waitrequest,
                input logic [3:0] slave_address,
                input logic slave_read, output logic [31:0] slave_readdata,
                input logic slave_write, input logic [31:0] slave_writedata,
                // master (SDRAM-facing)
                input logic master_waitrequest,
                output logic [31:0] master_address,
                output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
                output logic master_write, output logic [31:0] master_writedata);

    // your code here

    logic slave_write_addr0;

    logic [31:0] dest_addr_start;
    logic [31:0] src_addr_start;
    logic [31:0] N;

    logic [31:0] dest_addr;
    logic [31:0] src_addr;
    logic [31:0] i;

    logic [31:0] in_data;

    typedef enum {
        NONE,
        RESTART,
        INCRE
    } ctrl_t;
    ctrl_t dest_addr_ctrl, src_addr_ctrl, i_ctrl;


    typedef enum{ // 3-bit gray code
        READY,
        WAIT_START,
        RD_i,
        STORE_RD,
        WR_i,
        STALL_WR,
        INCREMENT,
        CHECK_N
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
            WAIT_START: begin
                next_state = RD_i;
            end
            RD_i  : begin
                next_state = ~master_waitrequest ? STORE_RD : RD_i;
            end
            STORE_RD: begin
                next_state = master_readdatavalid ? WR_i : STORE_RD;
            end
            WR_i  : begin
                next_state = ~master_waitrequest ? STALL_WR : WR_i;
            end
            STALL_WR : begin
                next_state = INCREMENT;
            end
            INCREMENT  : begin
                next_state = CHECK_N;
            end
            CHECK_N: begin
                next_state = (i == N) ? READY : RD_i;
            end
            default: begin // includes READY
                next_state = slave_write_addr0 ? WAIT_START : READY;
            end
        endcase
    end

    // FSM Output Logic
    always_comb begin
        slave_waitrequest = 1'b0;
        master_address = '0;
        master_read = 1'b0;
        master_write = 1'b0;
        master_writedata = '0;

        dest_addr_ctrl = NONE;
        src_addr_ctrl = NONE;
        i_ctrl = NONE;

        case (curr_state)
            READY : begin
                dest_addr_ctrl = RESTART;
                src_addr_ctrl = RESTART;
                i_ctrl = RESTART;
            end
            WAIT_START: begin
                slave_waitrequest = 1'b1; // stall CPU
            end
            RD_i  : begin
                slave_waitrequest = 1'b1; // stall CPU
                master_read = 1'b1;
                master_address = src_addr;
            end
            STORE_RD: begin
                slave_waitrequest = 1'b1; // stall CPU
            end
            WR_i  : begin
                slave_waitrequest = 1'b1; // stall CPU
                master_address = dest_addr;
                master_write = 1'b1;
                master_writedata = in_data;
            end
            STALL_WR: begin
                slave_waitrequest = 1'b1; // stall CPU
            end
            INCREMENT: begin
                slave_waitrequest = 1'b1; // stall CPU
                src_addr_ctrl = INCRE;
                dest_addr_ctrl = INCRE;
                i_ctrl = INCRE;
            end
            CHECK_N: begin
                slave_waitrequest = 1'b1; // stall CPU
            end
            default: begin
               //
            end
        endcase
    end
    

    // dest_addr register
    always_ff @(posedge clk) begin
        if (!rst_n || dest_addr_ctrl == RESTART) begin
            dest_addr <= dest_addr_start;
        end else if (dest_addr_ctrl == INCRE) begin
            dest_addr <= dest_addr + 32'd4;
        end
    end

    // dest_src register
    always_ff @(posedge clk) begin
        if (!rst_n || src_addr_ctrl == RESTART) begin
            src_addr <= src_addr_start;
        end else if (dest_addr_ctrl == INCRE) begin
            src_addr <= src_addr + 32'd4;
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

    // register to store data from input readdata
    always_ff @(posedge clk) begin
        if (master_readdatavalid) begin
            in_data <= master_readdata;
        end
    end

    assign slave_write_addr0 = (slave_address == 0) & slave_write;

    logic [31:0] mem [0:15];
    ///////////////////////////////////////////////////////////////////////////////
    // Inferred synchronous single-port RAM with common read and write addresses //
    ///////////////////////////////////////////////////////////////////////////////
    assign dest_addr_start = mem[4'd1];
    assign src_addr_start = mem[4'd2];
    assign N = mem[4'd3];
    always @(posedge clk)
    begin
        if (slave_write) begin
            mem[slave_address] <= slave_writedata;
        end
        // if (slave_read) begin
        //     slave_readdata <= mem[slave_address];
        // end
    end
    
    // // Outputs
    // assign slave_readdata = '0; // undefined
    assign slave_readdata = mem[slave_address];

endmodule: wordcopy
