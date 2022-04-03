module load_decider (
    input wire clock,
    input wire selector [1:0],
    input wire in_data [31:0],
    output wire data_out[31:0]
);
    always @(posedge clock) begin
        case(selector)
            2'b00: data_out = { {24{1'b0}} , Data_in[7:0] };//byte
            2'b01: data_out = { {16{1'b0}} , Data_in[15:0] };//half word
            2'b10: data_out = Data_in;//word
        endcase
    end  
endmodule