module Sign_extend_8 (
    input wire [7:0] Data_in,
    output wire [31:0] Data_out
);

assign Data_out = {{24{1'b0}}, Data_in};
    
endmodule