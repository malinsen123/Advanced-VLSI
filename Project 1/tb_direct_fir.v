`timescale 1ns / 1ps

module fir_filter_tb;

// Parameters for the testbench (matching the FIR filter's interface)
reg clk;
reg reset;
reg signed [31:0] x_in;
wire signed [31:0] y_out;

// Instantiate the FIR Filter module
fir_filter uut (
    .clk(clk),
    .reset(reset),
    .x_in(x_in),
    .y_out(y_out)
);

// Clock generation
always #5 clk = ~clk; // 100MHz clock

// Testbench stimulus
initial begin
    // Initialize Inputs
    clk = 0;
    reset = 1;
    x_in = 0;

    // Wait 100 ns for global reset to finish
    #100;
    
    reset = 0; // Release reset
    
    // Apply a simple input signal to the filter
    #10 x_in = 32'sd100;
    #10 x_in = 32'sd200;
    #10 x_in = 32'sd300;
    #10 x_in = 32'sd400;
    #10 x_in = 32'sd500;
    #10 x_in = 32'sd0; // Then send zeros to observe the filter's impulse response
    
    // Finish simulation after some time
    #500;
    $finish;
end

endmodule
