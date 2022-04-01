module mux13_5 (
    input wire [2:0] selector,
    input wire [31:0] data_0,
    input wire [31:0] data_1,
    input wire [31:0] data_2,
    input wire [31:0] data_3,
    input wire [31:0] data_4,
    output wire [31:0] data_out
);

    always @(selector) begin
        case(selector)
            3'b000: data_out = data_0;
            3'b001: data_out = data_1;
            3'b010: data_out = data_2;
            3'b011: data_out = data_3;
            3'b100: data_out = data_4;
            default: data_out = data_0;   
        endcase 
    end
    
endmodule