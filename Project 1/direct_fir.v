module fir_filter (
    input wire clk,                  // Clock signal
    input wire reset,                // Asynchronous reset
    input wire signed [31:0] x_in,   // 32-bit signed input sample
    output reg signed [31:0] y_out   // 32-bit signed output sample
);

// Number of taps
localparam integer N_TAPS = 100;

// Filter coefficients
parameter signed [31:0] h[N_TAPS-1:0] = {
    32'sd0, 32'sd0, 32'sd2, 32'sd0, 32'sd-3, 32'sd-2, 32'sd5, 32'sd6, 32'sd-5, 32'sd-12, 
    32'sd1, 32'sd18, 32'sd9, 32'sd-22, 32'sd-24, 32'sd19, 32'sd44, 32'sd-4, 32'sd-62, 32'sd-26, 
    32'sd70, 32'sd70, 32'sd-58, 32'sd-120, 32'sd16, 32'sd163, 32'sd60, 32'sd-178, 32'sd-163, 32'sd145, 
    32'sd277, 32'sd-47, 32'sd-370, 32'sd-122, 32'sd404, 32'sd351, 32'sd-337, 32'sd-608, 32'sd128, 32'sd840, 
    32'sd253, 32'sd-973, 32'sd-830, 32'sd904, 32'sd1652, 32'sd-456, 32'sd-2926, 32'sd-965, 32'sd6224, 32'sd13038, 
    32'sd13038, 32'sd6224, 32'sd-965, 32'sd-2926, 32'sd-456, 32'sd1652, 32'sd904, 32'sd-830, 32'sd-973, 32'sd253, 
    32'sd840, 32'sd128, 32'sd-608, 32'sd-337, 32'sd351, 32'sd404, 32'sd-122, 32'sd-370, 32'sd-47, 32'sd277, 
    32'sd145, 32'sd-163, 32'sd-178, 32'sd60, 32'sd163, 32'sd16, 32'sd-120, 32'sd-58, 32'sd70, 32'sd70, 
    32'sd-26, 32'sd-62, 32'sd-4, 32'sd44, 32'sd19, 32'sd-24, 32'sd-22, 32'sd9, 32'sd18, 32'sd1, 
    32'sd-12, 32'sd-5, 32'sd6, 32'sd5, 32'sd-2, 32'sd-3, 32'sd0, 32'sd2, 32'sd0, 32'sd0
};

// Sample shift register
reg signed [31:0] shift_reg[N_TAPS-1:0];

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
        // Shift the samples and compute the output in a single loop for simplicity
        y_out <= 0;
        for (i = N_TAPS-1; i > 0; i = i - 1) begin
            shift_reg[i] <= shift_reg[i-1]; // Shift the samples
            y_out <= y_out + (h[i] * shift_reg[i]); // Accumulate the result
        end
        shift_reg[0] <= x_in; // Input the new sample
        y_out <= y_out + (h[0] * x_in); // Add contribution from the newest sample
    end
end

endmodule

