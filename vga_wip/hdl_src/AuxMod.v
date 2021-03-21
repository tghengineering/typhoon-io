// A generic synchroniser to avoid metastability
module Synchroniser(DataInput, Clock, DataOutput);

	input 		DataInput;
	input 		Clock;
	output reg	DataOutput;
	
	
	reg 		intermediate; // Used as an intermediate Flip Flop
	
	// Pass Datainput through two Flipflops
	always @(posedge Clock) begin
	
		intermediate <= DataInput;
		DataOutput <= intermediate;
	
	end	
	
endmodule

// Remove the 'bounces' from the input signal
module Debounce(Clock, Sig, Desig);
	localparam NUM_CLOCKS = 1500000;

	input 			Clock;			// System clock
	input 			Sig;			// Signal from external source (switches)
	output	reg 	Desig;			// The debounced signal to output
	
	wire 			syncedSig; 		// Wire coming out of Synchroniser module
	reg		[20:0] 	count;  		// Need at least 21 bits to count to 1500000
	reg 			lastSyncedSig; 	// For comparing to current synced signal
	
	// Synchronise the input
	Synchroniser syncer(
		.DataInput(Sig), 
		.Clock(Clock), 
		.DataOutput(syncedSig)
	);
	
	always @(posedge Clock) begin
		
		// Change state of lastSyncedSig for the next clock cycle
		lastSyncedSig <= syncedSig;
		
		/* If state of the synced signal changed since last clock,
			restart the counter, else increment count */
		if (lastSyncedSig !== syncedSig) begin
			count <= 0;
		end
		else begin 
			count <= count + 1;
			// If the count is bigger that 1.5 million, set output to syncedSig
			if (count >= NUM_CLOCKS) begin
				Desig <= syncedSig;
			end
		end
		
		
	end
	
endmodule

// Detect the falling edge of a push button
module DetectFallingEdge(input Clock, btn_sync, output reg detected);
	
	reg btn_sync_last;	// Stores the current value of btn_sync for comparison next clock
	
	always @(posedge Clock) begin
			
		btn_sync_last <= btn_sync;	// Change value of last_output for next clock cycle
		
		/* If the last output for btn_sync was 1 and the current value of btn_sync is 0
		   then a falling edge of the button has been detected, else not detected		*/
		if (btn_sync_last == 1 && btn_sync == 0) begin
			detected <= 1;
		end
		else begin
			detected <= 0;
		end
		
	end


endmodule

// Display a Hexadecimal Digit, a Negative Sign, or a Blank, on a 7-segment Display
module SSeg(input [3:0] bin, input neg, input enable, output reg [6:0] segs);
	always @(*)
		if (enable) begin
			if (neg) segs = 7'b011_1111;
			else begin
				case (bin)
					0: segs = 7'b100_0000;
					1: segs = 7'b111_1001;
					2: segs = 7'b010_0100;
					3: segs = 7'b011_0000;
					4: segs = 7'b001_1001;
					5: segs = 7'b001_0010;
					6: segs = 7'b000_0010;
					7: segs = 7'b111_1000;
					8: segs = 7'b000_0000;
					9: segs = 7'b001_1000;
					10: segs = 7'b000_1000;
					11: segs = 7'b000_0011;
					12: segs = 7'b100_0110;
					13: segs = 7'b010_0001;
					14: segs = 7'b000_0110;
					15: segs = 7'b000_1110;
				endcase
			end
		end
		else segs = 7'b111_1111;
endmodule


// Module displays an 8 bit number on two 7-segment displays
module DispHex(Datain, disp0, disp1);
	
	
	input [7:0] Datain;
	output [6:0] disp0, disp1;
	
	// 4 most significant bits are to displayed on the far left display on FPGA
	SSeg leftDisp(Datain[7:4], 0, 1, disp1);
	// 4 least significant bits are to be display on the display next to the far left on FPGA
	SSeg rightDisp(Datain[4:0], 0, 1, disp0);
	

endmodule


// Module takes in a signed input and displayes it on 4, 7-segment displays
module Disp2cNum( dataIn, enable, disp3, disp2, disp1, disp0);

	input signed [7:0] dataIn;
	input enable;
	
	// The 4 rightmost displays
	output [6:0] disp3, disp2, disp1, disp0;
	
	// Determine if number is negative
	wire neg = (dataIn < 0);  
	
	// Obtain unsigned version on input
	wire [7:0] ux = neg ? -dataIn : dataIn; // Magnitude of input

   // Remainders of numbers to display
	wire [7:0] xo0, xo1, xo2, xo3;  
	
	// Enables for next display
	wire eno0, eno1, eno2, eno3;    
	 
	

	// Chain the displays together to display a single decimal number
	DispDec DispDec0(ux, neg, enable, xo0, eno0, disp0);
	DispDec DispDec1(xo0, neg, eno0, xo1, eno1, disp1);
	DispDec DispDec2(xo1, neg, eno1, xo2, eno2, disp2);
	DispDec DispDec3(xo2, neg, eno2, xo3, eno3, disp3);
	
endmodule  

// Display a decimal number on a display
module DispDec(
	input [7:0] x, 
	input neg, enable, 
	output reg [7:0] xo, 
	output reg eno, 
	output [6:0] segs
);  
	
	
	
	// Number to be displayed if enabled
	wire [3:0] digit = (x % 10);
	
	/* If x is 0 and neg is 1 then display a negative number 
	   (whether the display is on at all determined by enable)
	*/
	wire n = ( (x == 0) & neg); 	
	
	always @(*) begin
		
		// Send remainder to output
		xo <= x / 10;
		
		
		// Determine whether the next display should be enabled
		eno <= enable && (n !== 1) && (( (x/10) !== 0) || (neg == 1));

	end

	// Output a digit onto a display with a 7-segment converter
	SSeg converter(digit, n, enable, segs);    


endmodule




