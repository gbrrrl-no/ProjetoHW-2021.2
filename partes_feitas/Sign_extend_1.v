module Sign_extend_1 (
    input wire Data_in,
    output wire [31:0] Data_out
);

    assign Data_out = {{31{1'b0}}, Data_in};
    
endmodule