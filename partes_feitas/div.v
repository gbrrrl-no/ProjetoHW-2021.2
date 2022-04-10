module div (
    input wire clk,
    input wire reset,
    input wire [31:0] in_A,
    input wire [31:0] in_B,
    input wire start_operation,

    output reg stop_operation,
    output reg div_zero,
    output reg [31:0] HI,
    output reg [31:0] LO
);
    reg [31:0] rest;
    reg [31:0] div;
    reg [31:0] dividend;
    reg [31:0] quotient;
    reg div_zero_erro;
    reg stop;

    assign HI = rest;
	assign LO = quotient;

    always @ (posedge clk) begin
        if(div_zero)begin
		    div_zero_erro = 0;
	    end
        else if(stop_operation)begin
			stop = 0;
		end
		else if (reset)begin
			div=32'b0;
			quotient=32'b0;
            dividend=32'b0;
            rest=32'b0;
            stop = 0;
		end
    end

endmodule