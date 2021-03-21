module mode_lut
(
	// Input Ports
	input clk,
	input reset_n,
	input [2:0] mode,
	input mode_change,

	// Output Ports
	output reg [11:0] h_disp,
	output reg [11:0] h_fporch,
	output reg [11:0] h_sync,
	output reg [11:0] h_bporch,
	output reg [11:0] v_disp,
	output reg [11:0] v_fporch,
	output reg [11:0] v_sync,
	output reg [11:0] v_bporch,
	output reg		   hs_polarity,
	output reg		   vs_polarity,
	output reg		   frame_interlaced

);

	// Module Item(s)
	
	//============= assign timing constant



// sync_polarity = 0: 
// ______    _________
//       |__|
//        sync (hs_vs)
//
// sync_polarity = 1: 
//        __
// ______|  |__________
//       sync (hs/vs)




always @(posedge clk or negedge reset_n)
begin
	
	if (!reset_n)
	begin
		{h_disp, h_fporch, h_sync, h_bporch} <= {12'd640, 12'd16, 12'd96, 12'd48}; 
		{v_disp, v_fporch, v_sync, v_bporch} <= {12'd480, 12'd10, 12'd2,  12'd33}; 
		{frame_interlaced, vs_polarity, hs_polarity} <= 3'b000;
	end
	else if (mode_change) 
	begin
	case(mode)
		`VGA_640x480p60: begin  // 640x480@60 25.175 MHZ
			{h_disp, h_fporch, h_sync, h_bporch} <= {12'd640, 12'd16, 12'd96, 12'd48}; 
			{v_disp, v_fporch, v_sync, v_bporch} <= {12'd480, 12'd10, 12'd2,  12'd33}; 
			{frame_interlaced, vs_polarity, hs_polarity} <= 3'b000;
		end
	
		`MODE_720x480: begin  // 720x480@60 27MHZ (VIC=3, 480P)
			{h_disp, h_fporch, h_sync, h_bporch} <= {12'd720, 12'd16, 12'd62, 12'd60}; // total: 858
			{v_disp, v_fporch, v_sync, v_bporch} <= {12'd480, 12'd9, 12'd6,  12'd30};  // total: 525
			{frame_interlaced, vs_polarity, hs_polarity} <= 3'b000;
		end
		`MODE_1024x768: begin //1024x768@60 65MHZ (XGA)
			{h_disp, h_fporch, h_sync, h_bporch} <= {12'd1024, 12'd24, 12'd136, 12'd160}; 
			{v_disp, v_fporch, v_sync, v_bporch} <= {12'd768,  12'd3,  12'd6,   12'd29}; 
			{frame_interlaced, vs_polarity, hs_polarity} <= 3'b000;
		end
		`MODE_1280x1024: begin //1280x1024@60   108MHZ (SXGA)
			{h_disp, h_fporch, h_sync, h_bporch} <= {12'd1280, 12'd48, 12'd112, 12'd248}; 
			{v_disp, v_fporch, v_sync, v_bporch} <= {12'd1024,  12'd1,  12'd3,   12'd38}; 
			{frame_interlaced, vs_polarity, hs_polarity} <= 3'b000;
		end	
		`FHD_1920x1080p60: begin
			{h_disp, h_fporch, h_sync, h_bporch} <= {12'd1920, 12'd88, 12'd44, 12'd148};
			{v_disp, v_fporch, v_sync, v_bporch} <= {12'd1080,  12'd4, 12'd5,  12'd36};
			{frame_interlaced, vs_polarity, hs_polarity} <= 3'b000;
		end		
		`VESA_1600x1200p60: begin
			{h_disp, h_fporch, h_sync, h_bporch} <= {12'd1600, 12'd64, 12'd192, 12'd304};
			{v_disp, v_fporch, v_sync, v_bporch} <= {12'd1200,  12'd1,  12'd3,   12'd46};
			{frame_interlaced, vs_polarity, hs_polarity} <= 3'b000;
		end
		default: begin
			{h_disp, h_fporch, h_sync, h_bporch} <= {12'd640, 12'd16, 12'd96, 12'd48}; 
			{v_disp, v_fporch, v_sync, v_bporch} <= {12'd480, 12'd10, 12'd2,  12'd33}; 
			{frame_interlaced, vs_polarity, hs_polarity} <= 3'b000;
		end
	endcase
	end
end


endmodule
