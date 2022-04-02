module SB (
    input wire [7:0] rt_in,
    input wire [23:0] mdr_in,
    output reg [31:0] sb_out
);

assign sb_out = {mdr_in, rt_in};

endmodule