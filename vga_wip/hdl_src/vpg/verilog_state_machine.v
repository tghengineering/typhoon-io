`include "vpg.h"
module verilog_state_machine (
	input 			clk,
	input 			reset_n,
	input 			clk_en,
	input 		[2:0]	timing_mode,
	input 			timing_mode_change,
	// check the bus signals
	input 					pll_reconfig_wait_request,
	output reg 	[8 :0] 	pll_reconfig_addr,  
	output reg 	[31:0] 	pll_reconfig_write_data, 
	output reg 				pll_reconfig_write
);

	 
	 // Select MIF address based on mode
	 reg [8 :0] mif_addr = 0;
	 always @(*)
	 begin
		case (timing_mode)
			`VGA_640x480p60:		mif_addr <= 9'd0;
			`MODE_720x480: 		mif_addr <= 9'd46;
			`MODE_1024x768:		mif_addr <= 9'd92;
			`MODE_1280x1024:		mif_addr <= 9'd148;
//			4:			mif_addr <= 9'd184; // Interlaced mode not in use
			`FHD_1920x1080p60:	mif_addr <= 9'd230;
			`VESA_1600x1200p60: 	mif_addr <= 9'd276;	
			default: 				mif_addr <= 9'd0;
		endcase
	 end
    
    reg [2:0] state;
    localparam CONF_NONE = 0;
    localparam CONF_INIT = 1;
    localparam CONF_CHANGE_MODE = 2;
    localparam CONF_PLL_IN_CHANGE = 3;
    localparam CONF_PLL_DONE = 4;


    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
      begin
        state <= CONF_NONE;
        pll_reconfig_addr <= 0;
        pll_reconfig_write_data <= 0;
        pll_reconfig_write <= 0;
      end
      else if (clk_en)
      begin
        case (state)

            CONF_NONE:  
            begin
              state <= CONF_INIT;
            end

            CONF_INIT:  
            begin
              if (timing_mode_change)
              begin
                  state <= CONF_CHANGE_MODE;
              end
              else
              begin
                  state <= CONF_INIT;
              end
            end

            CONF_CHANGE_MODE:  
            begin
				
					if (!pll_reconfig_wait_request )
					begin
						state <= CONF_PLL_IN_CHANGE;
						pll_reconfig_write 		<= 1'b1;
						pll_reconfig_addr 		<= 9'h010;
						pll_reconfig_write_data <= mif_addr;
						
					end
					else
					begin
						state <= CONF_CHANGE_MODE;
						
					end
				  
            end

            CONF_PLL_IN_CHANGE:  
            begin
					pll_reconfig_write 		<= 1'b0;
              if (!pll_reconfig_wait_request)
              begin
                state <= CONF_PLL_DONE;
              end
              else 
              begin
                state <= CONF_PLL_IN_CHANGE;
					 
              end
            end
            
            CONF_PLL_DONE: 
            begin
              state <= CONF_INIT;
            end
            
            default:
            begin
              state <= CONF_NONE;
              pll_reconfig_addr <= 0;
              pll_reconfig_write_data <= 0;
              pll_reconfig_write <= 0;
            end
        endcase
      end
endmodule
