module mult (
    input wire clk,
    input wire reset,
    input wire [31:0] in_A,
    input wire [31:0] in_B,

    output reg [31:0] HI,
    output reg [31:0] LO,
);

reg [5:0] counter;
reg [64:0] AQQ_1, m;

always @(posedge clk) begin
    if (reset) begin
        AQQ_1 = 65'b0;
        m = 65'b0;
        counter = 6'b0;
    end
    else begin
        if (counter < 6'b100000) begin
            if (AQQ_1[1] != AQQ_1[0]) begin
                if (AQQ_1[1]) begin
                    //
                end 
                else begin
                    //
                end
            end
        end
    end
end
endmodule