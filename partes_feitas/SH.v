module SH(
    input wire [15:0] rt_in,
    input wire [15:0] mdr_in,
    output reg [31:0] sh_out
);

    assign sh_out = {mdr_in, rt_in};

endmodule