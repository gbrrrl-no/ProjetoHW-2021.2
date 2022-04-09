module shift_left16 (
    input wire [31:0] Data_in,
    output wire [31:0] Data_out
);

    assign Data_out = Data_in << 16;
    
endmodule