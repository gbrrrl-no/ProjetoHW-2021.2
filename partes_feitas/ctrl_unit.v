module ctrl_unit (
    input wire                clk,
    input wire                reset,

    // flags
    input wire                Overflow,
    input wire                Negativo,
    input wire                Zero,
    input wire                Igual,
    input wire                Maior,
    input wire                Menor,

    // meaningful part of the instruction
    input wire                [5:0] opcode,

    // controllers with 1 bit
    output reg                PC_w,
    output reg                memoria_w,
    output reg                IR_control,
    output reg                a_w,
    output reg                b_w,

    // controllers with more than 1 bit
    output reg                [2:0] ula_selector,

    // controllers for muxes
    output reg                [2:0] mux1_s,
    output reg                [2:0] mux2_s,
    output reg                [2:0] mux3_s,
    output reg                [2:0] mux4_s,
    output reg                [2:0] mux5_s,
    output reg                [2:0] mux13_s,

    // special controller for reset instruction
    output reg                res_out,
);

// variables
reg [3:0] counter;
reg [2:0] state;

// parameters
    // main states
    parameter st_common = 2'b00;
    parameter st_reset = 2'b11;
    // opcode aliases

initial begin
    res_out = 1'ba;
end

always @(posedge clk) begin
    if(reset==1'b1)begin
        if(state != st_reset)begin
            state = st_reset;
            PC_w = 1'b0;  //ok
            memoria_w = 1'b0; //ok
            IR_control = 1'b0; //ok
            reg_w = 1'b0; //ok 
            a_w = 1'b0; //ok
            b_w = 1'b0; //ok
            ALUOut_w = 1'b0; //ok
            ula_selector = 3'b000; //ok
            reset_out = 1'b1; ///
            mux1_s = 2'b000;
            mux2_s = 2'b000;
            mux3_s = 2'b000;
            mux4_s = 2'b000;
            mux5_s = 2'b000;
            mux13_s = 2'b000;

            counter = 3'b0000;
        end
        else begin
            state = st_common;
            PC_w = 1'b0;
            memoria_w = 1'b0;
            IR_control = 1'b0;
            reg_w = 1'b0;
            a_w = 1'b0;
            b_w = 1'b0;
            ALUOut_w = 1'b0;
            ula_selector = 3'b000;
            reset_out = 1'b0; ///
            mux1_s = 2'b000;
            mux2_s = 2'b000;
            mux3_s = 2'b000;
            mux4_s = 2'b000;
            mux5_s = 2'b000;
            mux13_s = 2'b000;
                       
            counter = 3'b0000;
        end
    end
    else begin
        case(state)
            st_common: begin
                if(counter == 3'b0000 || counter == 3'b0001 || counter == 3'b0010) begin
                    state = st_common;

                    PC_w = 1'b0;
                    memoria_w = 1'b0;
                    IR_control = 1'b0;
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0;
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b001;
                    reset_out = 1'b0; 
                    mux1_s = 2'b000;
                    mux2_s = 2'b000;
                    mux3_s = 2'b000;
                    mux4_s = 2'b000;
                    mux5_s = 2'b001; ///
                    mux13_s = 2'b000;  

                    counter = 3'b0000;                
                end
                else if(counter == 3'b0011) begin
                    state = st_common;
                    
                    PC_w = 1'b0;
                    memoria_w = 1'b0;
                    IR_control = 1'b0; ///
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0;
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001;
                    reset_out = 1'b0; 
                    mux1_s = 2'b000;
                    mux2_s = 2'b000;
                    mux3_s = 2'b000;
                    mux4_s = 2'b000;
                    mux5_s = 2'b001; 
                    mux13_s = 2'b000;  

                    counter = 3'b0000;   
                end    
                else if(counter == 3'b0100) begin
                    state = st_common;
                    
                    PC_w = 1'b0;
                    memoria_w = 1'b0;
                    IR_control = 1'b0; ///
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0;
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b001;
                    reset_out = 1'b0; 
                    mux1_s = 2'b000;
                    mux2_s = 2'b000;
                    mux3_s = 2'b000;
                    mux4_s = 2'b000;
                    mux5_s = 2'b001; 
                    mux13_s = 2'b001;  

                    counter = 3'b0000;   
                end     
                else if(counter == 3'b0101) begin
                    state = st_common;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1; ///
                    b_w = 1'b1; ///
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b001;
                    reset_out = 1'b0; 
                    mux1_s = 2'b000;
                    mux2_s = 2'b000;
                    mux3_s = 2'b000;
                    mux4_s = 2'b000;
                    mux5_s = 2'b001; 
                    mux13_s = 2'b001;  

                    counter = 3'b0000;   
                end   
                else if(counter == 3'b0110 || counter == 3'b0111 || counter == 3'b1000) begin
                    state = st_common;
                    
                    PC_w = 1'b0; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; ///
                    b_w = 1'b0; ///
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001;
                    reset_out = 1'b0; 
                    mux1_s = 2'b000;
                    mux2_s = 2'b000;
                    mux3_s = 2'b000;
                    mux4_s = 2'b000; ///
                    mux5_s = 2'b011; ///
                    mux13_s = 2'b001;  

                    counter = 3'b0000;   
                end  
                else if(counter == 3'b1001) begin 
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b001;
                    reset_out = 1'b0; 
                    mux1_s = 2'b000;
                    mux2_s = 2'b000;
                    mux3_s = 2'b000;
                    mux4_s = 2'b000; 
                    mux5_s = 2'b011; 
                    mux13_s = 2'b001;  

                    counter = 3'b0000;   
                end         
            end
        endcase
    end
end

endmodule