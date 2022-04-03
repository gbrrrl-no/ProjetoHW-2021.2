module mux14_2 (
    input wire [2:0] selector,
    input wire [31:0] data_0,
    input wire [31:0] data_1,
    output reg [31:0] data_out
);

   always @(selector) begin
        case(selector)
            3'b000: data_out = data_0;
            3'b001: data_out = data_1;
            default: data_out = data_0;    
        endcase
    end

endmodule