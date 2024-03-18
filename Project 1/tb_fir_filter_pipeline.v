`timescale 1ns / 1ps

module tb_fir_filter_pipelined;

// Testbench Signals
reg clk;
reg reset;
reg signed [31:0] x_in;
wire signed [31:0] y_out;

// Clock Generation
parameter CLK_PERIOD = 20; // Clock period in ns
always begin
    clk = 1'b0;
    #(CLK_PERIOD / 2) clk = 1'b1;
    #(CLK_PERIOD / 2);
end

// Instantiate the Unit Under Test (UUT)
fir_filter_pipelined uut (
    .clk(clk),
    .reset(reset),
    .x_in(x_in),
    .y_out(y_out)
);

initial begin
    // Initialize Inputs
    reset = 1;
    x_in = 0;

    // Wait for the global reset
    #(CLK_PERIOD * 5);
    
    reset = 0; // Release reset
    
    // Apply Input Stimulus
    // Here, we're simply ramping up the input to see the filter's response over time
    repeat (200) begin
        @(posedge clk);
        x_in = x_in + 1;
    end
    
    // Wait a bit and finish the simulation
    #(CLK_PERIOD * 100);
    $finish;
end

endmodule
