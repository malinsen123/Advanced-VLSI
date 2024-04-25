`define M 4                 // GF(2^9) 4 for testing
`define N (2**`M-1)			// GF(2^9) - 1 = 511 15 for testing
`define K 7 				// Number of information bits 7 for testing

// modulo operation
function [3:0] field_modulo(input [7:0] inp);
	if(inp >= 2*`N)
		field_modulo = inp - 2*`N;
	else if(inp >= `N)
		field_modulo = inp - 1*`N;
	else
		field_modulo = inp;
endfunction
