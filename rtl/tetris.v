`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/11/15 19:38:52
// Design Name: 
// Module Name: tetris
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tetris(
    input CLOCK_50,
     input		[ 9:0]		SW,
    input		[ 3:0]		KEY,
	 
	 
      ///////// HEX0 /////////
      output	[ 6:0]		HEX0,

      ///////// HEX1 /////////
      output	[ 6:0]		HEX1,

      ///////// HEX2 /////////
      output	[ 6:0]		HEX2,

      ///////// HEX3 /////////
      output	[ 6:0]		HEX3,

      ///////// HEX4 /////////
      output	[ 6:0]		HEX4,

      ///////// HEX5 /////////
      output	[ 6:0]		HEX5,
		
		      ///////// AUD /////////
      input					AUD_ADCDAT,
      inout					AUD_ADCLRCK,
      inout					AUD_BCLK,
      output				AUD_DACDAT,
      inout					AUD_DACLRCK,
      output				AUD_XCK,
		     ///////// LEDR /////////
      output	reg [ 9:0]		LEDR,

      ///////// PS2 /////////
      inout					PS2_CLK,
      inout					PS2_CLK2,
      inout					PS2_DAT,
      inout					PS2_DAT2,

	       ///////// VGA /////////
      output	[ 7:0]		VGA_B,
      output				VGA_BLANK_N,
      output				VGA_CLK,
      output	[ 7:0]		VGA_G,
      output				VGA_HS,
      output	[ 7:0]		VGA_R,
      output				VGA_SYNC_N,
      output				VGA_VS

    );
    
     parameter ROW = 20;
    parameter COL = 10;
    
       
    wire [3:0] opcode;
    wire gen_random;
    wire hold;
    wire shift;
    wire move_down;
    wire remove_1;
    wire remove_2;
    wire stop;
    wire move;
    wire isdie;
    wire shift_finish;
    wire down_comp;
    wire move_comp;
    wire die;
    wire [ROW*COL-1:0] data_out;
    
    wire [6:0] BLOCK;
    wire [3:0] m;
    wire [4:0] n;
    wire [(ROW+4)*COL-1:0] M_OUT;
    
    wire auto_down;
    wire remove_2_finish;
    wire rst_n;
    //assign rst_n =SW[0];
	 
	 wire vsync_r;
    wire hsync_r;
    wire [3:0]OutRed, OutGreen;
    wire [3:0]OutBlue;
	 wire clk_vga;
	 wire clk_100m;
	 wire [23:0] mSEG7_DIG;
	 
	 wire AUD_CTRL_CLK;
	 
	 
	 wire [7:0] ps2_key_data;
	 wire       ps2_key_pressed;
	 
	 reg ps2_rotate;
    reg ps2_left;
    reg ps2_right;
    reg ps2_down;
	       ///////// VGA /////////
//-----------------------
	
assign 	VGA_B ={OutBlue,4'b0}; 
assign   VGA_G ={OutGreen,4'b0};
assign 	VGA_R ={OutRed,4'b0};
assign   VGA_HS = hsync_r;
assign   VGA_VS = vsync_r;
assign   VGA_BLANK_N = hsync_r&vsync_r;
assign   VGA_SYNC_N =1'b0;
assign   VGA_CLK = clk_vga;
assign mSEG7_DIG = {16'b0,ps2_key_data};

assign AUD_ADCLRCK	= 1'bz;     					
assign AUD_DACLRCK	= 1'bz;     					
assign AUD_DACDAT	= 1'bz;     					
assign AUD_BCLK		= 1'bz;     						
assign AUD_XCK		= 1'bz;     						


assign AUD_XCK		= AUD_CTRL_CLK;
assign AUD_ADCLRCK	= AUD_DACLRCK;

//--------------------------------------

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
reg [31:0] cnt;
reg        start;
 
 always @(posedge CLOCK_50 or negedge rst_n) begin
   if(!rst_n) begin
	  ps2_rotate<=1'b0;
     ps2_left<=1'b0;
     ps2_right<=1'b0;
     ps2_down<=1'b0;
	  LEDR<=10'b0;
	  cnt<=0;
	end
	else begin
	  if(ps2_key_pressed==1'b1)
	    start<=1'b1;
	  else if(cnt==32'd1_800_000)
	    start<=1'b0;
		 
	  if(start==1'b1)
	    cnt<=cnt+1;
	  else
	    cnt<=0;
	  
	  if(ps2_key_pressed==1'b1&&ps2_key_data==8'h1d)begin//W
        ps2_rotate<=1'b1;
        ps2_left<=1'b0;
        ps2_right<=1'b0;
        ps2_down<=1'b0;
		  LEDR<=10'b00000_00001;
	  end
	  else if(ps2_key_pressed==1'b1&&ps2_key_data==8'h1b)begin//S
        ps2_left<=1'b0;
		  ps2_rotate<=1'b0;
        ps2_right<=1'b0;
        ps2_down<=1'b1;
		  LEDR<=10'b00000_00010;
     end
		  
	  else if(ps2_key_pressed==1'b1&&ps2_key_data==8'h1c)begin//A
        ps2_right<=1'b0;
		  ps2_rotate<=1'b0;
        ps2_left<=1'b1;
        ps2_down<=1'b0;
		  LEDR<=10'b00000_00100;
	  end  
	  else if(ps2_key_pressed==1'b1&&ps2_key_data==8'h23) begin//D
        ps2_down<=1'b0;
		  ps2_rotate<=1'b0;
        ps2_left<=1'b0;
        ps2_right<=1'b1;
		  LEDR<=10'b00000_01000;
     end
	  else if(cnt==32'd1_800_000) begin
	  	  ps2_rotate<=1'b0;
        ps2_left<=1'b0;
        ps2_right<=1'b0;
        ps2_down<=1'b0;
	     LEDR<=10'b0;
	  end
		
	end
 end

PLL UPLL(
	 .refclk(CLOCK_50),   //  refclk.clk
	 .rst(SW[0]),      //   reset.reset
	 .outclk_0(clk_100m), // outclk0.clk
	 .outclk_1 (AUD_CTRL_CLK), // outclk1.clk
	 .locked(rst_n)    //  locked.export
	);


    
    key u_key (
        .clk(clk_100m),
        .rst_n(rst_n),
        .UP_KEY(~KEY[0]),
        .LEFT_KEY(~KEY[1]),
        .RIGHT_KEY(~KEY[2]),
        .DOWN_KEY(~KEY[3]),
        .rotate(rotate),
        .left(left),
        .right(right),
        .down(down)
    );
    
	 
    game_control_unit u_Controller (
        .clk(clk_100m),
        .rst_n(rst_n),
        .rotate(ps2_rotate),
        .left(ps2_left),
        .right(ps2_right),
        .down(ps2_down),
        .start(SW[1]),
		  .ps2_key_pressed(ps2_key_pressed),
        .opcode(opcode),
        .gen_random(gen_random),
        .hold(hold),
        .shift(shift),
        .move_down(move_down),
        .remove_1(remove_1),
        .remove_2(remove_2),
        .stop(stop),
        .move(move),
        .isdie(isdie),
        .shift_finish(shift_finish),
        .down_comp(down_comp),
        .move_comp(move_comp),
        .die(die),
        .auto_down(auto_down),
        .remove_2_finish(remove_2_finish)
        );
        
    Datapath_Unit u_Datapath (
        .clk(clk_100m),
        .rst_n(rst_n),
        .NEW(gen_random),
        .MOVE(move),
        .DOWN(move_down),
        .DIE(isdie),
        .SHIFT(shift),
        .REMOVE_1(remove_1),
        .REMOVE_2(remove_2),
        .KEYBOARD(opcode),
        .MOVE_ABLE(move_comp),
        .SHIFT_FINISH(shift_finish),
        .DOWN_ABLE(down_comp),
        .DIE_TRUE(die),
        .M_OUT(M_OUT),
        .n(n),
        .m(m),
        .BLOCK(BLOCK),
        .REMOVE_2_FINISH(remove_2_finish),
        .STOP(stop),
        .AUTODOWN(auto_down)
        );
        
    merge u_merge (
        .clk(clk_100m),
        .rst_n(rst_n),
        .data_in(M_OUT),
        .shape(BLOCK),
        .x_pos(m),
        .y_pos(n),
        .data_out(data_out)
        
        );
	 
    top u_VGA (
        .clk(CLOCK_50),
        .rst(rst),
		  .clk_vga(clk_vga),
        .number(data_out),
        .hsync_r(hsync_r),
        .vsync_r(vsync_r),
        .OutRed(OutRed),
        .OutGreen(OutGreen),
        .OutBlue(OutBlue)        
	);
    

//----------------------------------
/*
game_control_unit u_Controller (
        .clk(clk_100m),
        .rst_n(rst_n),
        .rotate(rotate),
        .left(left),
        .right(right),
        .down(down),
        .start(SW[1]),
        .opcode(opcode),
        .gen_random(gen_random),
        .hold(hold),
        .shift(shift),
        .move_down(move_down),
        .remove_1(remove_1),
        .remove_2(remove_2),
        .stop(stop),
        .move(move),
        .isdie(isdie),
        .shift_finish(shift_finish),
        .down_comp(down_comp),
        .move_comp(move_comp),
        .die(die),
        .auto_down(auto_down),
        .remove_2_finish(remove_2_finish)
        );
        
    Datapath_Unit u_Datapath (
        .clk(clk_100m),
        .rst_n(rst_n),
        .NEW(gen_random),
        .MOVE(move),
        .DOWN(move_down),
        .DIE(isdie),
        .SHIFT(shift),
        .REMOVE_1(remove_1),
        .REMOVE_2(remove_2),
        .KEYBOARD(opcode),
        .MOVE_ABLE(move_comp),
        .SHIFT_FINISH(shift_finish),
        .DOWN_ABLE(down_comp),
        .DIE_TRUE(die),
        .M_OUT(M_OUT),
        .n(n),
        .m(m),
        .BLOCK(BLOCK),
        .REMOVE_2_FINISH(remove_2_finish),
        .STOP(stop),
        .AUTODOWN(auto_down)
        );
        
    merge u_merge (
        .clk(clk_100m),
        .rst_n(rst_n),
        .data_in(M_OUT),
        .shape(BLOCK),
        .x_pos(m),
        .y_pos(n),
        .data_out(data_out)
        
        );	
        
Tetris_vga UTetris_vga(
           .clk(pixel_clk),
           .reset_n(rst_n),
           .x_pos(hcount),//hcount,
           .y_pos(vcount),//vcount,        
   
           .num(data_out),
           .vga_de(VGA_DE),
   
           .vga_rgb(vga_rgb)
    );   
	     
vga_ctl U_vga_ctl(
        .pix_clk(pixel_clk),
        .reset_n(rst_n),
        .VGA_RGB(vga_rgb),
        .hcount(hcount),
        .vcount(vcount),
		.VGA_CLK(),
        .VGA_R(R),
        .VGA_G(G),
        .VGA_B(B),
        .VGA_HS(HS),
        .VGA_VS(VS),
        .VGA_DE(VGA_DE),
        .BLK()
        );  

*/
//---------------------------------
	 //-------------------------
// 7 segment LUT
SEG7_LUT_6 SEG7_LUT_6_inst (
	.oSEG0			(HEX0),
	.oSEG1			(HEX1),
	.oSEG2			(HEX2),
	.oSEG3			(HEX3),
	.oSEG4			(HEX4),
	.oSEG5			(HEX5),
	.iDIG			(mSEG7_DIG)
);

//-------------------------------
PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~rst_n),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

//---------------------------
	
AUDIO_DAC AUDIO_DAC_inst (
	// Audio Side
	.oAUD_BCK		(AUD_BCLK),
	.oAUD_DATA		(AUD_DACDAT),
	.oAUD_LRCK		(AUD_DACLRCK),
		
	// Control Signals
	.iSrc_Select	(2'b0),
	.iCLK_18_4		(AUD_CTRL_CLK),
	.iRST_N			(rst_n)
);	



    
endmodule
