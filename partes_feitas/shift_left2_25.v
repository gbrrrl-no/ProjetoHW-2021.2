module shift_left2_25 (
    input wire [24:0] Data_in,
    output wire [24:0] Data_out
);

    assign Data_out = Data_in << 2;
    
endmodule