module mux2_5 (
    input wire [2:0] selector,
    input wire [4:0] data_0,
    input wire [4:0] data_1,
    input wire [4:0] data_2,
    output reg [4:0] data_out
);

    always @(selector) begin
        case(selector)
            3'b000: data_out = data_0;
            3'b001: data_out = data_1;
            3'b010: data_out = data_2;
            3'b011: data_out = 5'b11101;
            3'b100: data_out = 5'b11111;
            default: data_out = data_0; 
        endcase   
    end
    
endmodule