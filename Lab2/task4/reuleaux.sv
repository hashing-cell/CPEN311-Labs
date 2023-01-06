`define SQRT3_3xDiameter {8'b00101110 , 8'b00110000 }
`define SQRT3_6xDiameter {8'b00010111 , 8'b00011000 }

`define SQRT3_3 {8'b00000000 , 11'b10010011110 }
`define SQRT3_6 {8'b00000000 , 11'b01001001111 }

module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     // draw the Reuleaux triangle

     //Fixed Point Values
     parameter FRAC_BITS = 11;
     parameter INT_BITS = 8;



     //Instantiating fillscreen (for Background)
     logic bg_rst, bg_start, bg_done, bg_plot;
     logic [2:0] bg_colour, bg_vga_colour;
     logic [7:0] bg_vga_x;
     logic [6:0] bg_vga_y;

     
     fillscreen bg(
          .clk (clk), 
          .rst_n (bg_rst), 
          .colour (bg_colour),
          .start (bg_start), 
          .done (bg_done),
          .vga_x (bg_vga_x), 
          .vga_y (bg_vga_y),
          .vga_colour (bg_vga_colour), 
          .vga_plot ( bg_plot)
          );

     //Instantiating circle
     logic circle_rst, circle_start, circle_done, circle_vga_plot;
     logic [2:0] circle_colour, circle_vga_colour;
     logic [7:0] circle_radius, circle_vga_x;
     logic [6:0] circle_vga_y;

     logic [FRAC_BITS + INT_BITS - 1:0] circle_center_x, circle_center_y, opposite_x1, opposite_y1, opposite_x2, opposite_y2;
     logic [1:0] which_corner;
     circle circleDraw(
          .clk (clk), 
          .rst_n (circle_rst), 
          .colour (circle_colour),
          .centre_x ( circle_center_x [INT_BITS + FRAC_BITS - 1: FRAC_BITS]), 
          .centre_y ( circle_center_y [INT_BITS + FRAC_BITS - 1: FRAC_BITS]), 
          .radius (circle_radius),
          .start (circle_start), 
          .done (circle_done),
          .vga_x (circle_vga_x), 
          .vga_y (circle_vga_y),
          .vga_colour (circle_vga_colour), 
          .vga_plot (circle_vga_plot),
          //              0  ,18:11 
          .bounds_x  ({1'b0 , opposite_x1 [INT_BITS + FRAC_BITS - 1: FRAC_BITS]}),
          .bounds_y  ({1'b0 , opposite_y1 [INT_BITS + FRAC_BITS - 1: FRAC_BITS]}),
          .bounds2_x ({1'b0 , opposite_x2 [INT_BITS + FRAC_BITS - 1: FRAC_BITS]}),
          .bounds2_y ({1'b0 , opposite_y2 [INT_BITS + FRAC_BITS - 1: FRAC_BITS]}),
          .which_corner (which_corner)
          );

     typedef enum { 
          RESET_ST,
          FILLBACKGROUND,
          CIRCLE_WAIT1,
          CIRCLE_DRAW1,
          CIRCLE_WAIT2,
          CIRCLE_DRAW2,
          CIRCLE_WAIT3,
          CIRCLE_DRAW3,
          DONE
	} state_t;

     state_t curr_state;

     //STATEMACHINE (Reset_ST state->Fill Background->Draw Circle 1->Draw Circle 2->Draw Circle 3->Done)
     always @(posedge clk) begin
          if(!rst_n) begin
               curr_state <= RESET_ST;
          end
          else 
          case (curr_state)
               RESET_ST:
               begin
                    if(start == 1)
                    begin
                         curr_state <= FILLBACKGROUND;
                    end 
                    else 
                    begin
                         curr_state <= curr_state;
                    end
               end
               FILLBACKGROUND:
               begin
                    if(bg_done == 1)
                    begin
                         curr_state <= CIRCLE_WAIT1;
                    end 
                    else 
                    begin
                         curr_state <= curr_state;
                    end
               end
               CIRCLE_DRAW1:
               begin 
                    if(circle_done == 1)
                    begin
                         curr_state <= CIRCLE_WAIT2;
                    end 
                    else 
                    begin
                         curr_state <= curr_state;
                    end
               end
               CIRCLE_DRAW2:
               begin 
                    if(circle_done == 1)
                    begin
                         curr_state <= CIRCLE_WAIT3;
                    end 
                    else 
                    begin
                         curr_state <= curr_state;
                    end
               end
               CIRCLE_DRAW3:
               begin 
                    if(circle_done == 1)
                    begin
                         curr_state <= DONE;
                    end 
                    else 
                    begin
                         curr_state <= curr_state;
                    end
               end
               DONE:
               begin
                    curr_state <= curr_state;
               end
               CIRCLE_WAIT1:
               begin
                    if(circle_done == 0)
                    begin
                         curr_state <= CIRCLE_DRAW1;   
                    end
                    else 
                    begin
                         curr_state <= curr_state; 
                    end
               end
               CIRCLE_WAIT2:
               begin
                    if(circle_done == 0)
                    begin
                         curr_state <= CIRCLE_DRAW2;   
                    end
                    else 
                    begin
                         curr_state <= curr_state; 
                    end
               end
               CIRCLE_WAIT3:
               begin
                    if(circle_done == 0)
                    begin
                         curr_state <= CIRCLE_DRAW3;   
                    end
                    else 
                    begin
                         curr_state <= curr_state; 
                    end
               end
               default:
               begin
                    curr_state <= RESET_ST;      
               end
          endcase
	end

     logic [29:0] sqrt3_6xdiameter;
     logic [29:0] sqrt3_3xdiameter;

     //Setting MACRO
     //Bundle of signals that change
     `define SIGBUNDLE {bg_rst, bg_start, bg_colour, circle_rst, circle_start, circle_colour, circle_radius}
     //Coordinates of Right Corner
     `define CORNERX1 {centre_x + (diameter >> 1), 11'b0};
     `define CORNERY1 {1'b0, centre_y, 11'd0} + {sqrt3_6xdiameter [29:11]};
     //Coordinates of Left Corner
     `define CORNERX2 {centre_x - (diameter >> 1), 11'b0};
     `define CORNERY2 {1'b0, centre_y, 11'd0} + {sqrt3_6xdiameter [29:11]};
     //Coordinates of TOP Corner
     `define CORNERX3 {centre_x, 11'b0};
     `define CORNERY3 {1'b0, centre_y, 11'd0} - {sqrt3_3xdiameter [29:11]};

     //Setting Signals
     always_comb begin : signalGenerator
          sqrt3_3xdiameter = ( `SQRT3_3 * {diameter, 11'd0});
          sqrt3_6xdiameter = ( `SQRT3_6 * {diameter, 11'd0});
          case (curr_state)
               //                                    {bg_rst, bg_start, bg_colour, circle_rst, circle_start, circle_colour, circle_radius}                          
               RESET_ST:      begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b0      , 1'b0        , 3'b100       , diameter  };
                                   circle_center_x = 16'd0;
                                   circle_center_y = 16'd0;
                                   opposite_x1     = 16'd0;
                                   opposite_y1     = 16'd0;
                                   opposite_x2     = 16'd0;
                                   opposite_y2     = 16'd0;
                                   which_corner = 2'b00;
                                   vga_x =     bg_vga_x;
                                   vga_y =     bg_vga_y;
                                   vga_colour= bg_vga_colour;
                                   vga_plot=   bg_plot;
                                   done = 1'b0;
                              end
               FILLBACKGROUND:begin
                                   `SIGBUNDLE      = {1'b1  , 1'b1    , 3'b000   , 1'b0      , 1'b0        , 3'b100       , diameter  };
                                   circle_center_x = 16'd0;
                                   circle_center_y = 16'd0;
                                   opposite_x1     = 16'd0;
                                   opposite_y1     = 16'd0;
                                   opposite_x2     = 16'd0;
                                   opposite_y2     = 16'd0;
                                   which_corner = 2'b00;
                                   vga_x =     bg_vga_x;
                                   vga_y =     bg_vga_y;
                                   vga_colour= bg_vga_colour;
                                   vga_plot=   bg_plot;
                                   done = 1'b0;                                   
                              end
               CIRCLE_WAIT1:  begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b0      , 1'b0        , 3'b100       , diameter  };
                                   circle_center_x = `CORNERX1;
                                   circle_center_y = `CORNERY1;
                                   //Opposing Corner 1
                                   opposite_x1     = `CORNERX3;
                                   opposite_y1     = `CORNERY3;
                                   //Opposing Corner 2
                                   opposite_x2     = `CORNERX2;
                                   opposite_y2     = `CORNERY2;
                                   which_corner = 2'b10;
                                   vga_x =     circle_vga_x;
                                   vga_y =     circle_vga_y;
                                   vga_colour= circle_vga_colour;
                                   vga_plot=   circle_vga_plot;
                                   done = 1'b0;
                              end
               CIRCLE_WAIT2:  begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b0      , 1'b0        , 3'b100       , diameter  };
                                   circle_center_x = `CORNERX2;
                                   circle_center_y = `CORNERY2;
                                   //Opposing Corner 1
                                   opposite_x1     = `CORNERX3;
                                   opposite_y1     = `CORNERY3;
                                   //Opposing Corner 2
                                   opposite_x2     = `CORNERX1;
                                   opposite_y2     = `CORNERY1;
                                   which_corner = 2'b01;
                                   vga_x =     circle_vga_x;
                                   vga_y =     circle_vga_y;
                                   vga_colour= circle_vga_colour;
                                   vga_plot=   circle_vga_plot;
                                   done = 1'b0;
                              end 
               CIRCLE_WAIT3:  begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b0      , 1'b0        , 3'b100       , diameter  };
                                   circle_center_x = `CORNERX3;
                                   circle_center_y = `CORNERY3;
                                   //Opposing Corner 1
                                   opposite_x1     = `CORNERX2;
                                   opposite_y1     = `CORNERY2;
                                   //Opposing Corner 2
                                   opposite_x2     = `CORNERX1;
                                   opposite_y2     = `CORNERY1;
                                   which_corner = 2'b11;
                                   which_corner = 2'b00;
                                   vga_x =     circle_vga_x;
                                   vga_y =     circle_vga_y;
                                   vga_colour= circle_vga_colour;
                                   vga_plot=   circle_vga_plot;
                                   done = 1'b0;
                              end     
               CIRCLE_DRAW1:  begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b1      , 1'b1        , 3'b010       , diameter  };
                                   //x = 120 ; y = 83.1
                                   circle_center_x = `CORNERX1;
                                   circle_center_y = `CORNERY1;
                                   //Opposing Corner 1
                                   opposite_x1     = `CORNERX3;
                                   opposite_y1     = `CORNERY3;
                                   //Opposing Corner 2
                                   opposite_x2     = `CORNERX2;
                                   opposite_y2     = `CORNERY2;
                                   which_corner = 2'b10;
                                   vga_x =     circle_vga_x;
                                   vga_y =     circle_vga_y;
                                   vga_colour= circle_vga_colour;
                                   vga_plot=   circle_vga_plot;
                                   done = 1'b0;
                              end           
               CIRCLE_DRAW2:  begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b1      , 1'b1        , 3'b010       , diameter  };
                                   //x = 40 ; y = 83.1
                                   circle_center_x = `CORNERX2;
                                   circle_center_y = `CORNERY2;
                                   //Opposing Corner 1
                                   opposite_x1     = `CORNERX3;
                                   opposite_y1     = `CORNERY3;
                                   //Opposing Corner 2
                                   opposite_x2     = `CORNERX1;
                                   opposite_y2     = `CORNERY1;
                                   which_corner = 2'b01;
                                   vga_x =     circle_vga_x;
                                   vga_y =     circle_vga_y;
                                   vga_colour= circle_vga_colour;
                                   vga_plot=   circle_vga_plot;
                                   done = 1'b0;
                              end       
               CIRCLE_DRAW3:  begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b1      , 1'b1        , 3'b010       , diameter  };
                                   //x = 80  ; y = 13.8
                                   circle_center_x = `CORNERX3;
                                   circle_center_y = `CORNERY3;
                                   //Opposing Corner 1
                                   opposite_x1     = `CORNERX2;
                                   opposite_y1     = `CORNERY2;
                                   //Opposing Corner 2
                                   opposite_x2     = `CORNERX1;
                                   opposite_y2     = `CORNERY1;
                                   which_corner = 2'b11;
                                   vga_x =     circle_vga_x;
                                   vga_y =     circle_vga_y;
                                   vga_colour= circle_vga_colour;
                                   vga_plot=   circle_vga_plot;
                                   done = 1'b0;
                              end       
               DONE:          begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b0      , 1'b0        , 3'b111       , diameter  };
                                   circle_center_x = 16'd0;
                                   circle_center_y = 16'd0;
                                   opposite_x1     = 16'd0;
                                   opposite_y1     = 16'd0;
                                   opposite_x2     = 16'd0;
                                   opposite_y2     = 16'd0;
                                   which_corner = 2'b00;
                                   vga_x =     8'd0;
                                   vga_y =     7'd0;
                                   vga_colour= 3'd0;
                                   vga_plot=   1'd0;
                                   done = 1'b1;
                              end
          default:            begin
                                   `SIGBUNDLE      = {1'b0  , 1'b0    , 3'b000   , 1'b0      , 1'b0        , 3'b111       , diameter  };
                                   circle_center_x = 16'd0;
                                   circle_center_y = 16'd0;
                                   opposite_x1     = 16'd0;
                                   opposite_y1     = 16'd0;
                                   opposite_x2     = 16'd0;
                                   opposite_y2     = 16'd0;
                                   which_corner = 2'b00;
                                   vga_x =     8'd0;
                                   vga_y =     7'd0;
                                   vga_colour= 3'd0;
                                   vga_plot=   1'd0;
                                   done = 1'b0;
                              end
               
          endcase
     end


endmodule

