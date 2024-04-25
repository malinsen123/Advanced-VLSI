module fir_filter (
    input wire clk,                  // Clock signal
    input wire reset,                // Asynchronous reset
    input wire signed [31:0] x_in,   // 32-bit signed input sample
    output reg signed [31:0] y_out   // 32-bit signed output sample
);

// Number of taps
localparam N_TAPS = 100;
wire signed [31:0] h [N_TAPS-1:0];

assign h[0] = 32'sd1;
assign h[1] = 32'sd2;
assign h[2] = 32'sd4;
assign h[3] = 32'sd0;
assign h[4] = -32'sd3;
assign h[5] = -32'sd2;
assign h[6] = 32'sd5;
assign h[7] = 32'sd6;
assign h[8] = -32'sd5;
assign h[9] = -32'sd12;
assign h[10] = 32'sd1;
assign h[11] = 32'sd18;
assign h[12] = 32'sd9;
assign h[13] = -32'sd22;
assign h[14] = -32'sd24;
assign h[15] = 32'sd19;
assign h[16] = 32'sd44;
assign h[17] = -32'sd4;
assign h[18] = -32'sd62;
assign h[19] = -32'sd26;
assign h[20] = 32'sd70;
assign h[21] = 32'sd70;
assign h[22] = -32'sd58;
assign h[23] = -32'sd120;
assign h[24] = 32'sd16;
assign h[25] = 32'sd163;
assign h[26] = 32'sd60;
assign h[27] = -32'sd178;
assign h[28] = -32'sd163;
assign h[29] = 32'sd145;
assign h[30] = 32'sd277;
assign h[31] = -32'sd47;
assign h[32] = -32'sd370;
assign h[33] = -32'sd122;
assign h[34] = 32'sd404;
assign h[35] = 32'sd351;
assign h[36] = -32'sd337;
assign h[37] = -32'sd608;
assign h[38] = 32'sd128;
assign h[39] = 32'sd840;
assign h[40] = 32'sd253;
assign h[41] = -32'sd973;
assign h[42] = -32'sd830;
assign h[43] = 32'sd904;
assign h[44] = 32'sd1652;
assign h[45] = -32'sd456;
assign h[46] = -32'sd2926;
assign h[47] = -32'sd965;
assign h[48] = 32'sd6224;
assign h[49] = 32'sd13038;
assign h[50] = 32'sd13038;
assign h[51] = 32'sd6224;
assign h[52] = -32'sd965;
assign h[53] = -32'sd2926;
assign h[54] = -32'sd456;
assign h[55] = 32'sd1652;
assign h[56] = 32'sd904;
assign h[57] = -32'sd830;
assign h[58] = -32'sd973;
assign h[59] = 32'sd253;
assign h[60] = 32'sd840;
assign h[61] = 32'sd128;
assign h[62] = -32'sd608;
assign h[63] = -32'sd337;
assign h[64] = 32'sd351;
assign h[65] = 32'sd404;
assign h[66] = -32'sd122;
assign h[67] = -32'sd370;
assign h[68] = -32'sd47;
assign h[69] = 32'sd277;
assign h[70] = 32'sd145;
assign h[71] = -32'sd163;
assign h[72] = -32'sd178;
assign h[73] = 32'sd60;
assign h[74] = 32'sd163;
assign h[75] = 32'sd16;
assign h[76] = -32'sd120;
assign h[77] = -32'sd58;
assign h[78] = 32'sd70;
assign h[79] = 32'sd70;
assign h[80] = -32'sd26;
assign h[81] = -32'sd62;
assign h[82] = -32'sd4;
assign h[83] = 32'sd44;
assign h[84] = 32'sd19;
assign h[85] = -32'sd24;
assign h[86] = -32'sd22;
assign h[87] = 32'sd9;
assign h[88] = 32'sd18;
assign h[89] = 32'sd1;
assign h[90] = -32'sd12;
assign h[91] = -32'sd5;
assign h[92] = 32'sd6;
assign h[93] = 32'sd5;
assign h[94] = -32'sd2;
assign h[95] = -32'sd3;
assign h[96] = 32'sd0;
assign h[97] = 32'sd2;
assign h[98] = 32'sd0;
assign h[99] = 32'sd0;


// Sample shift register
reg signed [31:0] shift_reg[N_TAPS-1:0];
reg signed [31:0] temp_y_out;



integer i;

// FIR filter main logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset logic: clear the shift register
        for (i = 0; i < N_TAPS; i = i + 1) begin
            shift_reg[i] <= 0;
        end
        y_out <= 0;
    end
    else begin
	// Shift the input sample through the register
        for (i = N_TAPS-1; i > 0; i = i - 1) begin
            shift_reg[i] <= shift_reg[i - 1];
        end
	shift_reg[0] <= x_in; // Input the new sampl
        temp_y_out <= 0;
        for (i = 0; i < N_TAPS; i = i +1) begin
            //shift_reg[i] <= shift_reg[i-1]; // Shift the samples
            temp_y_out = temp_y_out + (h[i] * shift_reg[i]); // Accumulate the result
        end

	y_out <= temp_y_out;
        //shift_reg[0] <= x_in; // Input the new sample
        //y_out <= y_out + (h[0] * x_in); // Add contribution from the newest sample
    end
end

endmodule

