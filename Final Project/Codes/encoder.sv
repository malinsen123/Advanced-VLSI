`include "helper.sv"

module serial_encoder(
	input  wire [`K-1:0] infor_bits, 
	output wire [`N-1:0] codeword_out,
	output reg  busy,
	output reg  output_valid,
	input  wire restart,
	input  wire en, clk, reset
);
	wire [`N-`K-0:0] generator = 9'b111010001;
	reg  [`N-`K-1:0] LFSR;		// generator has 0 to N-K bits
	reg  [`M-1 :0] counter;		// runs from 0 .. `K-1. The whole length of the message.
	reg  [`K-1 :0] infor_bits_latched; // latched infor_bits

	wire last_input_sample = (counter == 0);			// while encoding is still underway.

	always @(posedge clk) begin
		if(reset) begin
			{infor_bits_latched, output_valid, busy} <= 0;
			counter <= `K-1;
		end
		else if(en) begin
			if(restart) begin
				infor_bits_latched <= infor_bits;
				counter <= `K-1;
				busy <= 1;
			end
			else if(busy) begin
				if(last_input_sample)
					busy <= 1'b0;

				counter <= counter - 1;
			end

			output_valid <= last_input_sample;
		end
	end

	// Main part. LFSR handle
	always @(posedge clk) begin
		if(reset)
			LFSR <= 0;
		else if(en) begin
			if(restart)
				LFSR <= 0;
			else if(busy) begin
				if(LFSR[`N-`K-1] ^ infor_bits_latched[counter])
					LFSR <= generator[`N-`K-1:0] ^ {LFSR[`N-`K-2:0], 1'b0};
				else
					LFSR <= {LFSR[`N-`K-2:0], 1'b0};
			end
		end
	end

	assign codeword_out = {infor_bits_latched, LFSR};
endmodule

module parallel_encoder(
	input  wire [`K-1:0] infor_bits,
	output wire [`N-1:0] codeword_out,
	output wire busy,
	output wire output_valid,
	input  wire restart,
	input  wire en, clk, reset
);
	integer i;
	parameter PIPELINE_DEPTH = 3;

	wire [`N-`K-0:0] generator = 9'b111010001;
	reg  [`N-`K-1:0] LFSR;		// generator has 0 to N-K bits
	wire [`K-1 :0] infor_bits_latched = infor_bits;

	// Serialized LFSR handle
	always @(*) begin
		LFSR = 0;

		for(i=`K-1; i>=0; i-=1) begin
			if(LFSR[`N-`K-1] ^ infor_bits_latched[i])
				LFSR = generator[`N-`K-1:0] ^ {LFSR[`N-`K-2:0], 1'b0};
			else
				LFSR = {LFSR[`N-`K-2:0], 1'b0};
		end
	end

	// Pipelining
	reg [`N-`K-1:0] pLFSR_PL [0:PIPELINE_DEPTH];
	reg valid_PL [0:PIPELINE_DEPTH];

	always @(*) pLFSR_PL[0] = LFSR;
	always @(*) valid_PL[0] = restart;

	always @(posedge clk) begin
		for(i=1; i<=PIPELINE_DEPTH; i+=1) begin
			if(reset)
				{valid_PL[i], pLFSR_PL[i]} <= 'b0;
			else if(en) begin
				valid_PL[i] <= valid_PL[i-1];
				pLFSR_PL[i] <= pLFSR_PL[i-1];
			end
		end
	end

	assign busy = valid_PL[PIPELINE_DEPTH-1];
	assign output_valid = valid_PL[PIPELINE_DEPTH];

	assign codeword_out = {infor_bits_latched, pLFSR_PL[PIPELINE_DEPTH]};
endmodule

module testbench;
	reg  [`K-1:0] infor_bits;
	wire [`N-1:0] codeword_out_serial, codeword_out_parallel;
	wire output_valid_serial, output_valid_parallel;
	reg  restart;
	reg  en, clk, reset;


	serial_encoder serial_bch_encoder_inst(
		.infor_bits(infor_bits),
		.codeword_out(codeword_out_serial),
		.output_valid(output_valid_serial),
		.restart(restart),
		.en(en), .clk(clk),
		.reset(reset)
	);

	parallel_encoder parallel_bch_encoder_inst(
		.infor_bits(infor_bits),
		.codeword_out(codeword_out_parallel),
		.output_valid(output_valid_parallel),
		.restart(restart),
		.en(en), .clk(clk),
		.reset(reset)
	);

	initial begin


		#0 en = 0; clk = 0; reset = 0;
		#1 reset = 1;
		#1 clk = 1;
		#1 clk = 0;
		#1 reset = 0;
		
		#1 en = 1;
		#1 infor_bits = 7'b1000000;
		#1 restart = 1;

		#1 clk = 1;
		#1 clk = 0;

		#1 restart = 0;

		repeat(20)
			#1 clk = ~clk;
	end
endmodule