// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
// MODIFIED BY: David Lynch
// DATE: 20/03/21

`include "vpg.h"

module vpg(
	clk_100,
	reset_n,
	mode,
	mode_change,
	disp_color,
	vpg_pclk,
	vpg_de,
	vpg_hs,
	vpg_vs,
	vpg_r,
	vpg_g,
	vpg_b
);


input					clk_100;
input					reset_n;
input		[3:0]		mode;
input					mode_change;
input		[1:0]		disp_color; 
output				vpg_pclk;
output				vpg_de;
output				vpg_hs;
output				vpg_vs;
output	[7:0] 	vpg_r;
output	[7:0] 	vpg_g;
output	[7:0] 	vpg_b;


//============= config sequnce control
`define CONFIG_NONE							0	
`define CONFIG_PLL_UPDATE_CONFIG_DONE	1
`define CONFIG_PLL_WAIT_STABLE			2
`define CONFIG_START_VPG  					3

reg	[3:0]	config_state;
reg 	[2:0] timing_change_dur;
reg			timing_change;

always @ (posedge clk_100 or negedge reset_n)
begin
	if (!reset_n)
	begin
		config_state 		<= `CONFIG_NONE;
		timing_change 		<= 1'b0;
		timing_change_dur <= 0;
	end	
	else if (mode_change)
	begin
		config_state 		<= `CONFIG_PLL_WAIT_STABLE;
		timing_change 		<= 1'b0;
		timing_change_dur <= 0;
	end		
	else if (config_state == `CONFIG_PLL_WAIT_STABLE && gen_clk_locked)
	begin
		config_state 		<= `CONFIG_START_VPG;
		timing_change_dur <= 3'b111;
		timing_change 		<= 1'b1;
	end		
	else if (config_state == `CONFIG_START_VPG)
	begin
		if (timing_change_dur)
			timing_change_dur <= timing_change_dur - 1'b1;
		else	
		begin
			config_state 	<= `CONFIG_NONE;
			timing_change 	<= 1'b0;
		end	
	end
	
		
end




//============= assign timing constant
wire [11:0] h_disp;
wire [11:0] h_fporch;
wire [11:0] h_sync;
wire [11:0] h_bporch;
wire [11:0] v_disp;
wire [11:0] v_fporch;
wire [11:0] v_sync;
wire [11:0] v_bporch;
wire 		   hs_polarity;
wire 		   vs_polarity;
wire 		   frame_interlaced;


mode_lut mode_mux_inst(
	// Input Ports
	.clk(clk_100),
	.reset_n(reset_n),
	.mode(mode),
	.mode_change(mode_change),

	// Output Ports
	.h_disp(h_disp),
	.h_fporch(h_fporch),
	.h_sync(h_sync),
	.h_bporch(h_bporch),
	.v_disp(v_disp),
	.v_fporch(v_fporch),
	.v_sync(v_sync),
	.v_bporch(v_bporch),
	.hs_polarity(hs_polarity),
	.vs_polarity(vs_polarity),
	.frame_interlaced(frame_interlaced)

);

//=============== PLL reconfigure

wire pll_rst = !reset_n;
wire gen_clk;
wire gen_clk_locked;
wire [63:0] reconfig_to_pll;
wire [63:0] reconfig_from_pll;

wire 				pll_reconfig_wait_request;
wire	[8 :0] 	pll_reconfig_addr;  
wire	[31:0] 	pll_reconfig_write_data; 
wire 				pll_reconfig_clk;
wire  			pll_reconfig_clk_en;
wire  			pll_reconfig_write;
	
vpg_pll vpg_pll_inst (
	.refclk            (clk_100),				//            refclk.clk
	.rst               (pll_rst),				//             reset.reset
	.outclk_0          (gen_clk),          //           outclk0.clk
	.locked            (gen_clk_locked),	//            locked.export
	.reconfig_to_pll   (reconfig_to_pll),	//   reconfig_to_pll.reconfig_to_pll
	.reconfig_from_pll (reconfig_from_pll)	// reconfig_from_pll.reconfig_from_pll
);

pll_reconfig_fsm vpg_pll_cnfg_mngr(
	.clk(clk_100),
	.reset_n(reset_n),
	.clk_en(1'b1),
	.timing_mode(mode),
	.timing_mode_change(mode_change),
	.pll_reconfig_wait_request(pll_reconfig_wait_request),
	.pll_reconfig_addr(pll_reconfig_addr),  
	.pll_reconfig_write_data(pll_reconfig_write_data), 
	.pll_reconfig_write(pll_reconfig_write)
);

vpg_pll_reconfig vgp_pll_reconfig_inst(
	.mgmt_clk(clk_100),										//          mgmt_clk.clk
	.mgmt_reset(pll_rst),									//        mgmt_reset.reset
	.mgmt_waitrequest(pll_reconfig_wait_request),	// mgmt_avalon_slave.waitrequest
	.mgmt_read(1'b0),											//                  .read
	.mgmt_write(pll_reconfig_write),						//                  .write
//	.mgmt_readdata(),     									//                  .readdata
	.mgmt_address(pll_reconfig_addr),					//                  .address
	.mgmt_writedata(pll_reconfig_write_data),			//                  .writedata
	.reconfig_to_pll(reconfig_to_pll),					//   reconfig_to_pll.reconfig_to_pll
	.reconfig_from_pll(reconfig_from_pll)				// reconfig_from_pll.reconfig_from_pll
	);	


//============ pattern generator: vga timming generator
wire time_hs;
wire time_vs;
wire time_de;

wire [11:0]	time_x;
wire [11:0]	time_y;

vga_time_generator vga_time_generator_inst(

           .clk(gen_clk),
           .reset_n(gen_clk_locked),
           .timing_change(timing_change),
        
           .h_disp(		h_disp),
           .h_fporch(	h_fporch),
           .h_sync(		h_sync),   
           .h_bporch(	h_bporch),
 
           .v_disp(		v_disp),
           .v_fporch(	v_fporch),
           .v_sync(		v_sync),   
           .v_bporch(	v_bporch),   
           
           .hs_polarity(hs_polarity),
           .vs_polarity(vs_polarity),
           .frame_interlaced(frame_interlaced),              
           

           .vga_hs(time_hs),
           .vga_vs(time_vs),
           .vga_de(time_de),
           .pixel_i_odd_frame(),
           .pixel_x(time_x),
           .pixel_y(time_y)
 
);		
	
//===== pattern generator according to vga timing

wire  		gen_hs;
wire  		gen_vs;
wire  		gen_de;
wire [7:0]	gen_r;
wire [7:0]	gen_g;
wire [7:0]	gen_b;

//convert time: 1-clock 
pattern_gen pattern_gen_inst(
	.reset_n(gen_clk_locked),
	.pixel_clk(gen_clk),
	.pixel_de(time_de),
	.pixel_hs(time_hs),
	.pixel_vs(time_vs),
	.pixel_x(time_x),
	.pixel_y(time_y),
	.image_width(h_disp),
	.image_height(v_disp),
	.image_color(disp_color),
	.gen_de(gen_de),
	.gen_hs(gen_hs),
	.gen_vs(gen_vs),
	.gen_r(gen_r),
	.gen_g(gen_g),
	.gen_b(gen_b)
);


//===== output
assign vpg_pclk 	= gen_clk;
assign vpg_de 		= gen_de;
assign vpg_hs 		= gen_hs;
assign vpg_vs 		= gen_vs;
assign vpg_r 		= gen_r;
assign vpg_g 		= gen_g;
assign vpg_b 		= gen_b;


endmodule

