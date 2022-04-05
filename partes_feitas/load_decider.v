module load_decider (
    input wire clock,
    input wire [1:0] selector,
    input wire [31:0] in_data,
    output reg [31:0] data_out
);
    always @(posedge clock) begin
        case(selector)
            2'b00: data_out = { {24{1'b0}} , in_data[7:0] };//byte
            2'b01: data_out = { {16{1'b0}} , in_data[15:0] };//half word
            2'b10: data_out = in_data;//word
        endcase
    end  
endmodule