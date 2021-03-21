module debounce_wrapper (
	input clk,
	input [9:0] SW,
	input [3:0] KEY,
	
	output [9:0] SW_deb,
	output [3:0] KEY_pressed
);

genvar i;

generate for(i = 0; i<=9; i = i + 1) 
begin : debounce_sw
	// Generate Items
	Debounce dsw (
		.Clock(clk),
		.Sig(SW[i]),
		.Desig(SW_deb[i])
	);
end
endgenerate

wire [3:0] KEY_deb;
generate for(i = 0; i<=3; i = i + 1) 
begin : debounce_keys
	// Generate Items
	Debounce dkey (
		.Clock(clk),
		.Sig(KEY[i]),
		.Desig(KEY_deb[i])
	);
end
endgenerate

generate for(i = 0; i<=3; i = i + 1) 
begin : pressed_keys
	// Generate Items
	DetectFallingEdge bpress (
		.Clock(clk),
		.btn_sync(KEY_deb[i]),
		.detected(KEY_pressed[i])
	);
end
endgenerate



endmodule 