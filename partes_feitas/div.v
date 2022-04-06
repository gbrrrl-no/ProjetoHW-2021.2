module div (
    input wire clk,
    input wire reset,
    input wire [31:0] in_A,
    input wire [31:0] in_B,
    input wire start_operation,

    output wire stop_operation,
    output wire div_zero,
    output reg [31:0] HI,
    output reg [31:0] LO
);
    
endmodule