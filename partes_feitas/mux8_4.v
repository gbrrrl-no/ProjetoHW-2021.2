module mux8_4 (
    input wire [2:0] selector,
    input wire [5:0] data_0,
    input wire [5:0] data_2,
    input wire [5:0] data_3,
    output wire [5:0] data_out
);

    always @(selector) begin
        case(selector)
            3'b000: data_out = data_0;
            3'b001: data_out = 6'd16;
            3'b010: data_out = data_2;
            3'b011: data_out = data_3;
            default: data_out = data_0; 
        endcase   
    end
    
endmodule