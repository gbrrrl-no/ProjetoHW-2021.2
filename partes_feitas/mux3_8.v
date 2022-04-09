module mux3_8 (
    input wire [2:0] selector,
    input wire [31:0] data_0,
    input wire [31:0] data_1,
    input wire [31:0] data_2,
    input wire [31:0] data_3,
    input wire [31:0] data_4,
    input wire [31:0] data_5,
    input wire [31:0] data_6,
    output reg [31:0] data_out
);

    always @(selector or data_0 or data_1 or data_2 or data_3 or data_4 or data_5 or data_6) begin
        case(selector)
            3'b000: data_out = data_0;
            3'b001: data_out = data_1;
            3'b010: data_out = data_2;
            3'b011: data_out = data_3;
            3'b100: data_out = data_4;
            3'b101: data_out = data_5;
            3'b110: data_out = data_6;
            3'b111: data_out = 32'd227;
            default: data_out = data_0;
        endcase    
    end
    
endmodule