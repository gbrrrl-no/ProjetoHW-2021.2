module mult (
    input wire clk,
    input wire reset,
    input wire [31:0] in_A,
    input wire [31:0] in_B,
    input wire start_operation,
    
    output wire stop_operation,
    output reg [31:0] HI,
    output reg [31:0] LO
);

reg run_operation;
reg [5:0] counter;
reg [31:0] m_operator, temp_A_operator;
reg [32:0] temp_QQ_1_operator;
reg [64:0] AQQ_1;

always @(posedge clk) begin
    if (reset) begin
        AQQ_1 = 65'b0;
        temp_QQ_1_operator = 33'b0;
        temp_A_operator = 32'b0;
        m_operator = 32'b0;
        counter = 6'b0;
        stop_operation = 0;
        run_operation = 0;
    end
    else begin
        if (start_operation) begin
            AQQ_1 = {{32'b0, in_A}, 1'b0};
            m_operator = in_B;
            start_operation = 0;
            run_operation = 1;
        end
        else if (run_operation) begin
            if (counter < 6'b100000) begin
                temp_A_operator = AQQ_1[64:33];
                temp_QQ_1_operator = AQQ_1[32:0];
                if (temp_QQ_1_operator[1] != temp_QQ_1_operator[0]) begin
                    if (temp_QQ_1_operator[1]) begin
                        temp_A_operator = temp_A_operator - m_operator;
                    end 
                    else begin
                        temp_A_operator = temp_A_operator + m_operator;
                    end
                end
                AQQ_1 = {temp_A_operator, temp_QQ_1_operator};
                AQQ_1 = AQQ_1>>>1;
                counter = counter + 1;
            end
            else begin
                HI = AQQ_1[64:33];
                LO = AQQ_1[32:1];
                run_operation = 0;
                stop_operation = 1;
            end
        end
    end
end
endmodule