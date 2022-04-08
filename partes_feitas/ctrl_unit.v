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
    input wire                stop_mult,

    // meaningful part of the instruction
    input wire                [5:0] funct,
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
    output reg                [2:0] mux6_s,
    output reg                [2:0] mux7_s,
    output reg                [2:0] mux8_s,
    output reg                [2:0] mux9_s,
    output reg                [2:0] mux10_s,
    output reg                [2:0] mux11_s,
    output reg                [2:0] mux12_s,
    output reg                [2:0] mux13_s,
    output reg                [2:0] mux14_s,
    output reg                temp_a_s,
    output reg                temp_b_s,
    output reg                hi_out_s,
    output reg                lo_out_s,
    output reg                start_mult,
    output reg                EPC_w,
    output reg                mem_dr_w,
    output reg                [2:0] load_dec_w,
    output reg                [2:0] reg_des_shift,
    output reg                ALUOut_w,
    output reg                reg_w,


    // special controller for reset instruction
    output reg                reset_out
);

// variables
reg [5:0] counter;
reg [5:0] state;

// // parameters

    // opcode aliases
    parameter opcode_addi   = 6'h08;
    parameter opcode_addiu  = 6'h09;
    parameter opcode_beq    = 6'h04;
    parameter opcode_bne    = 6'h05;
    parameter opcode_ble    = 6'h06;
    parameter opcode_bgt    = 6'h07;
    parameter opcode_sllm   = 6'h01;
    parameter opcode_lb     = 6'h20;
    parameter opcode_lh     = 6'h21;
    parameter opcode_lui    = 6'h0F;
    parameter opcode_lw     = 6'h23;
    parameter opcode_sb     = 6'h28;
    parameter opcode_sh     = 6'h29;
    parameter opcode_slti   = 6'h0A;
    parameter opcode_sw     = 6'h2B;

    // type J opcode
    parameter opcode_j   = 6'h02;
    parameter opcode_jal = 6'h03;
    
//     //reset
//     parameter RESET  = 6'h11;//QUEM SABE ESSE VALOR?

    //funct aliases 17
    // parameter funct_over_f = 6'b111111;//deve ser mudado
    parameter funct_add    = 6'h20;
    parameter funct_and    = 6'h24;
    parameter funct_div    = 6'h1A; 
    parameter funct_mult   = 6'h18;
    parameter funct_jr     = 6'h08;
    parameter funct_mfhi   = 6'h10;
    parameter funct_mflo   = 6'h12;
    parameter funct_sll    = 6'h00;//zero
    parameter funct_sllv   = 6'h04;
    parameter funct_slt    = 6'h2A;
    parameter funct_sra    = 6'h03;
    parameter funct_srav   = 6'h07;
    parameter funct_srl    = 6'h02;
    parameter funct_sub    = 6'h22;
    parameter funct_break  = 6'h0D;
    parameter funct_Rte    = 6'h13;
    parameter funct_addm   = 6'h05;     
    
//     //excecoes
//     parameter excecao_op_ines = 6'h0A;
//     parameter excecao_overflow = 6'h0B;

//-------------


    // main states
    parameter st_common = 16'b00;
    parameter st_reset  = 16'b11;

    // state aliases
    parameter addi   = 6'h01;
    parameter addiu  = 6'h02;
    parameter beq    = 6'h03;
    parameter bne    = 6'h04;
    parameter ble    = 6'h05;
    parameter bgt    = 6'h06;
    parameter sllm   = 6'h07;
    parameter lb     = 6'h08;
    parameter lh     = 6'h09;
    parameter lui    = 6'h0A;
    parameter lw     = 6'h0B;
    parameter sb     = 6'h0C;
    parameter sh     = 6'h0D;
    parameter slti   = 6'h0E;
    parameter sw     = 6'h0F;

    //instructions type J
    parameter st_j   = 6'h10;
    parameter st_jal = 6'h11;
    
    //reset
    parameter RESET  = 6'h12;//QUEM SABE ESSE VALOR?

    //funct state aliases 17
    // parameter st_over_f = 6'b111111;//deve ser mudado
    parameter st_add    = 6'h13;
    parameter st_and    = 6'h14;
    parameter st_div    = 6'h15; 
    parameter st_mult   = 6'h16;
    parameter st_jr     = 6'h17;
    parameter st_mfhi   = 6'h18;
    parameter st_mflo   = 6'h19;
    parameter st_sll    = 6'h1A;//zero
    parameter st_sllv   = 6'h1B;
    parameter st_slt    = 6'h1C;
    parameter st_sra    = 6'h1D;
    parameter st_srav   = 6'h1E;
    parameter st_srl    = 6'h1F;
    parameter st_sub    = 6'h20;
    parameter st_break  = 6'h21;
    parameter st_Rte    = 6'h22;
    parameter st_addm   = 6'h23;     
    
    //excecoes
    parameter excecao_op_ines = 6'h24;
    parameter excecao_overflow = 6'h25;
    parameter excecao_div0 = 6'h26;

initial begin
    reset_out = 1'b1;
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
            mux1_s = 3'b000;
            mux2_s = 3'b000;
            mux3_s = 3'b000;
            mux4_s = 3'b000;
            mux5_s = 3'b000;
            mux6_s = 3'b000;
            mux7_s = 3'b000;
            mux8_s = 3'b000;
            mux9_s = 3'b000;
            mux10_s = 3'b000;
            mux12_s = 3'b000;
            mux13_s = 3'b000;
            mux11_s = 3'b000;
            mux14_s = 3'b000;
            reset_out = 1'b1; ///
            temp_a_s = 1'b0;
            temp_b_s = 1'b0;
            hi_out_s = 1'b0;
            lo_out_s = 1'b0;
            EPC_w = 1'b0;
            mem_dr_w = 1'b0;
            load_dec_w = 2'b00;
            reg_des_shift = 3'b000;
            
            counter = 6'b000000;
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
            mux1_s = 3'b000;
            mux2_s = 3'b000;
            mux3_s = 3'b000;
            mux4_s = 3'b000;
            mux5_s = 3'b000;
            mux6_s = 3'b000;
            mux7_s = 3'b000;
            mux8_s = 3'b000;
            mux9_s = 3'b000;
            mux10_s = 3'b000;
            mux12_s = 3'b000;
            mux13_s = 3'b000;
            mux11_s = 3'b000;
            mux14_s = 3'b000;
            reset_out = 1'b0; ///
            temp_a_s = 1'b0;
            temp_b_s = 1'b0;
            hi_out_s = 1'b0;
            lo_out_s = 1'b0;
            EPC_w = 1'b0;
            mem_dr_w = 1'b0;
            load_dec_w = 2'b00;
            reg_des_shift = 3'b000;
                       
            counter = 6'b000000;
        end
    end
    else begin
        case(state)
            st_common: begin
                if(counter == 6'b000000 || counter == 6'b000001 || counter == 6'b000010) begin
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
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;                
                end
                else if(counter == 6'b000011) begin
                    state = st_common;
                    
                    PC_w = 1'b0;
                    memoria_w = 1'b0;
                    IR_control = 1'b1; ///
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0;
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000; 
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end    
                else if(counter == 6'b000100) begin
                    state = st_common;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b1; ///
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0;
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b011; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end     
                else if(counter == 6'b000101) begin
                    state = st_common;
                    
                    PC_w = 1'b0; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1; ///
                    b_w = 1'b1; ///
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b011; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end   
                else if(counter == 6'b000110 || counter == 6'b000111 || counter == 6'b001000) begin
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
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b011; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end  
                else if(counter == 6'b001001) begin 
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b011; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end         
                else if(counter == 6'b001010) begin
                    case (opcode)
                        st_reset: begin
                            state = st_reset;
                        end
                        opcode_j:begin
                            state = st_j;
                        end
                        opcode_jal:begin
                            state = st_jal;
                        end
                        opcode_addi:begin
                            state = addi;
                        end
                        opcode_addiu:begin
                            state = addiu;
                        end
                        opcode_beq:begin
                            state = beq;
                        end
                        opcode_ble:begin
                            state = ble;
                        end
                        opcode_sllm:begin
                            state = sllm;
                        end
                        opcode_lb:begin
                            state = lb;
                        end
                        opcode_lh:begin
                            state = lh;
                        end
                        opcode_lui:begin
                            state = lui;
                        end
                        opcode_lw:begin
                            state = lw;
                        end
                        opcode_sb:begin
                            state = sb;
                        end
                        opcode_sh:begin
                            state = sh;
                        end
                        opcode_slti:begin
                            state = slti;
                        end
                        opcode_sw:begin
                            state = sw;
                        end
                        6'b000000: begin
                            case (funct)
                                funct_add: begin
                                    state = st_add;
                                end
                                funct_and: begin
                                    state = st_and;
                                end
                                funct_div: begin
                                    state = st_div;
                                end
                                funct_mult: begin
                                    state = st_mult;
                                end
                                funct_jr: begin
                                    state = st_jr;
                                end
                                funct_mfhi: begin
                                    state = st_mfhi;
                                end
                                funct_mflo: begin
                                    state = st_mflo;
                                end
                                funct_sll: begin
                                    state = st_sll;
                                end
                                funct_sllv: begin
                                    state = st_sllv;
                                end
                                funct_slt: begin
                                    state = st_slt;
                                end
                                funct_sra: begin
                                    state = st_sra;
                                end
                                funct_srav: begin
                                    state = st_srav;
                                end
                                funct_srl: begin
                                    state = st_srl;
                                end
                                funct_sub: begin
                                    state = st_sub;
                                end
                                funct_break: begin
                                    state = st_break;
                                end
                                funct_Rte: begin
                                    state = st_Rte;
                                end
                                funct_addm: begin
                                    state = st_addm;
                                end 
                            endcase
                        end
                        default: begin //excecao
                            state = excecao_op_ines;
                        end
                    endcase
                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;
                end
            end

            //================= and =======================
            st_and: begin
                if (counter == 6'b000000 || counter == 6'b000001 || counter == 6'b000010) begin
                    state = st_and;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b011;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000011) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010; ///
                    mux3_s = 3'b001; ///
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;   
                end
            end
            //================= add =======================
            st_add: begin
                if (counter == 6'b000000) begin
                    state = st_add;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000001 && Overflow) begin
                    state = excecao_overflow;
                    counter = 6'b000000;
                end
                else if (counter == 6'b000001) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010; ///
                    mux3_s = 3'b001; ///
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;   
                end
            end
            //================= addi =======================
            addi: begin
                if (counter == 6'b000000) begin
                    state = addi;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000001 && Overflow) begin
                    state = excecao_overflow;
                    counter = 6'b000000;
                end
                else if (counter == 6'b000001) begin
                    state = addi;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b001;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b001;
                    mux3_s = 3'b001;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;
                end 
                else if (counter == 6'b000010) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000; ///
                    mux3_s = 3'b000; ///
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;   
                end
            end
            //================= addiu =======================
            addiu: begin
                if (counter == 6'b000000) begin
                    state = addiu;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = addiu;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b001;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b001;
                    mux3_s = 3'b001;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;
                end 
                else if (counter == 6'b000010) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000; ///
                    mux3_s = 3'b000; ///
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;   
                end
            end
            //================= sub =======================
            st_sub: begin
                if (counter == 6'b000000) begin
                    state = st_sub;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b010;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000001 && Overflow) begin
                    state = excecao_overflow;
                    counter = 6'b000000;
                end
                else if (counter == 6'b000001) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010; ///
                    mux3_s = 3'b001; ///
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;   
                end
            end
            //================= break =======================
            st_break: begin
                if (counter == 6'b000000) begin
                    state = st_break;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b010;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b001; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = st_common;
                    
                    PC_w = 1'b1; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000; ///
                    mux3_s = 3'b000; ///
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;   
                end
            end
            //================= rte =======================
            st_Rte: begin
                if (counter == 6'b000000) begin
                    state = st_common;
                    
                    PC_w = 1'b1; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010; ///
                    mux3_s = 3'b001; ///
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b011;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;   
                end
            end
            //================= mult ======================
            st_mult: begin
                if (counter == 6'b000000) begin
                    if (!stop_mult) begin
                       state = st_mult;
                       start_mult = 1'b1;
                    end 
                    else begin
                        state = st_common;
                        start_mult = 0;
                    end

                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b1;
                    lo_out_s = 1'b1;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;   
                end
            end
            //================= mfhi ======================
            st_mfhi: begin
                if (counter == 6'b000000) begin
                    state = st_mfhi;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b010;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000000) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b010;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;   
                end
            end
            //================= mflo ======================
            st_mflo: begin
                if (counter == 6'b000000) begin
                    state = st_mflo;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b011;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000000) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b011;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;   
                end
            end
            //================= sll ======================
            st_sll: begin
                if (counter == 6'b000000) begin
                    state = st_sll;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b001;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = st_sll;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b010;
                    mux9_s = 3'b010;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b010;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000010) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b101;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b010;
                    mux9_s = 3'b010;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b010;
                    
                    counter = 6'b000000;   
                end
            end
            //================= sllv ======================
            st_sllv: begin
                if (counter == 6'b000000) begin
                    state = st_sllv;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b001;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = st_sllv;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b010;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000010) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b101;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b010;
                    
                    counter = 6'b000000;   
                end
            end
            //================= sra ======================
            st_sra: begin
                if (counter == 6'b000000) begin
                    state = st_sra;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b001;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = st_sra;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b010;
                    mux9_s = 3'b010;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b011;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000010) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b101;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b010;
                    mux9_s = 3'b010;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b011;
                    
                    counter = 6'b000000;   
                end
            end
            //================= srav ======================
            st_srav: begin
                if (counter == 6'b000000) begin
                    state = st_srav;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b001;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = st_srav;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b011;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000010) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b101;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b011;
                    
                    counter = 6'b000000;   
                end
            end
            //================= srl ======================
            st_srl: begin
                if (counter == 6'b000000) begin
                    state = st_srl;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b001;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = st_srl;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b010;
                    mux9_s = 3'b010;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b011;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000010) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b101;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b010;
                    mux9_s = 3'b010;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b011;
                    
                    counter = 6'b000000;   
                end
            end
            //================= slt ======================
            st_slt: begin
                if (counter == 6'b000000) begin
                    state = st_slt;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b111;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b110;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;   
                end
            end
            //================= slti ======================
            slti: begin
                if (counter == 6'b000000) begin
                    state = slti;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b111;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = slti;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b010;
                    mux3_s = 3'b110;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;   
                end
                else if (counter == 6'b000010) begin
                    state = st_common;
                
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;   
                end
            end
            //================= jr ========================
            st_jr: begin
                if (counter == 6'b000000) begin
                    state = st_common;

                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; ///
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; ///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000; ///
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;
                end
            end
            //================= beq =======================
            beq: begin
                if (counter == 6'b000000) begin
                    state = beq;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if(counter == 6'b000001 || counter == 6'b000010)begin
                    state = beq;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000011 && Igual)begin
                    state = beq;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001; ///
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000100)begin
                    state = st_common;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;
                end
                if(counter == 6'b000011 && !Igual) begin
                    state = st_common;
                    counter = 6'b000000;
                end
            end
            //================= bne =======================
            bne: begin
                if (counter == 6'b000000) begin
                    state = bne;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if(counter == 6'b000001 || counter == 6'b000010)begin
                    state = bne;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000011 && !Igual)begin
                    state = bne;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001; ///
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000100)begin
                    state = st_common;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;
                end
                if(counter == 6'b000011 && !Igual) begin
                    state = st_common;
                    counter = 6'b000000;
                end
            end
            //================= ble =======================
            ble: begin
                if (counter == 6'b000000) begin
                    state = ble;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if(counter == 6'b000001 || counter == 6'b000010)begin
                    state = ble;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000011 && (Igual || Menor)) begin
                    state = ble;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001; ///
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000100)begin
                    state = st_common;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;
                end
                if(counter == 6'b000011 && !Igual) begin
                    state = st_common;
                    counter = 6'b000000;
                end
            end
            //================= bgt =======================
            bgt: begin
                if (counter == 6'b000000) begin
                    state = bgt;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if(counter == 6'b000001 || counter == 6'b000010)begin
                    state = bgt;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000011 && Maior)begin
                    state = bgt;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001; ///
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000100)begin
                    state = st_common;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b110;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b001;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;
                end
                if(counter == 6'b000011 && !Igual) begin
                    state = st_common;
                    counter = 6'b000000;
                end
            end
            //================= sb =======================
            sb: begin 
                if (counter == 6'b000000) begin
                    state = sb;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1; ///
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b000;
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000010) begin
                    state = sb;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;  
                end
                else if (counter == 6'b000011) begin
                    state = sb;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b010; ///
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;    
                end
                else if (counter == 6'b000100 || counter == 6'b000101 || counter == 6'b000110) begin
                    state = sb;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b010;
                    reset_out = 1'b0;
                    mux1_s = 3'b001;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;    
                end
                else if (counter == 6'b000111) begin
                    state = sb;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b1; ///
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b010;
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b100; ///
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;    
                end
                else if (counter == 6'b001000) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0; ///
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; ///
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b010;
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b100;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;    
                end
            end
            //================= sh ========================
            sh: begin 
                if (counter == 6'b000000) begin
                    state = sh;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1; ///
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b000;
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000001) begin
                    state = sh;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;  
                end
                else if (counter == 6'b000010) begin
                    state = sh;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b010; ///
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;    
                end
                else if (counter == 6'b000011 || counter == 6'b000100 || counter == 6'b000101) begin
                    state = sh;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b010;
                    reset_out = 1'b0;
                    mux1_s = 3'b001;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;    
                end
                else if (counter == 6'b000110) begin
                    state = sh;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b1; ///
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b010;
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b011; ///
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;    
                end
                else if (counter == 6'b000111) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0; ///
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; ///
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b010;
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b100;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;    
                end
            end
            //================= sw ========================
            sw: begin 
                if (counter == 6'b000000) begin
                    state = sw;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b1; ///
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b001;
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;
                end
                else if (counter == 6'b000001) begin
                    state = sw;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b001;
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000010) begin
                    state = sw;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001; ///
                    reset_out = 1'b0;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;   
                end
                else if (counter == 6'b000011 || counter == 6'b000100 || counter == 6'b000101) begin
                    state = sw;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b001;
                    reset_out = 1'b0;
                    mux1_s = 3'b001;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;
                end
                else if (counter == 6'b000110) begin
                    state = sw;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b1; ///
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0;
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b001;
                    reset_out = 1'b0;
                    mux1_s = 3'b001;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b010; ///
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1;
                end
                else if (counter == 6'b000111) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0; ///
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; ///
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b001;
                    reset_out = 1'b0;
                    mux1_s = 3'b001;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;
                end
            end
            //================= lb ========================
            lb: begin
                if (counter == 6'b000000 || counter == 6'b000001) begin
                    state = lb;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000010) begin
                    state = lb;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000011)begin 
                    state = lb;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000100 || counter == 6'b000101)begin
                    state = lb;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000110) begin
                    state = lb;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000111) begin
                    state = lb;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter+1;
                end
                else if (counter == 6'b001000) begin
                    state = st_common;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;
                end
            end
            //================= lh ========================
            lh: begin
                if (counter == 6'b000000 || counter == 6'b000001) begin
                    state = lh;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b01;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000010) begin
                    state = lh;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b01;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000011)begin 
                    state = lh;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b01;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000100 || counter == 6'b000101)begin
                    state = lh;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b01;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000110) begin
                    state = lh;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b01;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000111) begin
                    state = lh;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b01;
                    reg_des_shift = 3'b000;
                    
                    counter = counter+1;
                end
                else if (counter == 6'b001000) begin
                    state = st_common;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b01;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;
                end
            end
            //================= lw ========================
            lw: begin
                if (counter == 6'b000000 || counter == 6'b000001) begin
                    state = lw;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000010) begin
                    state = lw;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000011)begin 
                    state = lw;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000100 || counter == 6'b000101)begin
                    state = lw;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000110) begin
                    state = lw;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000111) begin
                    state = lw;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b001000) begin
                    state = st_common;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b001; 
                    mux1_s = 3'b001;
                    mux2_s = 3'b001;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;
                end
            end
            //================= lui =====================
            lui: begin 
                if (counter == 6'b000000 || counter == 6'b000001) begin
                    if (counter == 6'b000000) begin
                        state = lui;
                    end
                    else begin
                        state = st_common;
                    end

                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000;
                    reset_out = 1'b0; ///
                    mux1_s = 3'b000;
                    mux2_s = 3'b001; ///
                    mux3_s = 3'b101; ///
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b001;
                    mux9_s = 3'b001;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b010;

                    if (counter == 6'b000000) begin
                        counter = counter +1;
                    end
                    else begin
                        counter = 6'b000000;
                    end  
                end
            end
            //================= J =========================
            st_j: begin
                if (counter == 6'b000000)begin
                    state = st_j;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b011;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b010;///
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000001) begin
                    state = st_common;
                    
                    PC_w = 1'b1; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; 
                    ula_selector = 3'b011;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b010; ///
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000; 
                end
            end
            //================= jal ======================= 
            st_jal: begin
                if (counter == 6'b000000)begin
                    state = st_jal;
                    
                    PC_w = 1'b0;
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; /// 
                    ula_selector = 3'b000; ///
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b100; ///
                    mux3_s = 3'b001; ///
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000001) begin
                    state = st_jal;
                    
                    PC_w = 1'b1; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; ///
                    ula_selector = 3'b000;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b100; 
                    mux3_s = 3'b001; 
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b010; ///
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = counter + 1; 
                end
                else if (counter == 6'b000010) begin
                    state = st_common;
                    
                    PC_w = 1'b0; ///
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000;
                    reset_out = 1'b0; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b100; 
                    mux3_s = 3'b001; 
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b010; 
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000; 
                end
            end
            //================= reset =====================
            st_reset: begin 
                if (counter == 6'b000000) begin
                    state = st_common;
                    
                    PC_w = 1'b0; 
                    memoria_w = 1'b0;
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000;
                    reset_out = 1'b1; ///
                    mux1_s = 3'b000;
                    mux2_s = 3'b100; ///
                    mux3_s = 3'b111; ///
                    mux4_s = 3'b000; 
                    mux5_s = 3'b000; 
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;  
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;

                    counter = 6'b000000;   
                end
            end
        //================= op_inexistente =====================    
            excecao_op_ines:begin
                if (counter == 6'b000000 || counter == 6'b000001) begin
                    state = excecao_op_ines;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b001; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b1;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if ( counter == 6'b000010 || counter == 6'b000011 || counter == 6'b000100) begin
                    state = excecao_op_ines;

                    PC_w = 1'b1;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b010;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000101) begin
                    state = excecao_op_ines;

                    PC_w = 1'b1;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b010;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000110) begin
                    state = st_common;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b010;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;
                end
            end
            //================= overflow =====================
            excecao_overflow:begin
                if (counter == 6'b000000 || counter == 6'b000001) begin
                    state = excecao_overflow;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b001; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b1;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if ( counter == 6'b000010 || counter == 6'b000011 || counter == 6'b000100) begin
                    state = excecao_overflow;

                    PC_w = 1'b1;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b011;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000101) begin
                    state = excecao_overflow;

                    PC_w = 1'b1;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b011;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000110) begin
                    state = st_common;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b011;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;
                end
            end
            //================= div_0 =====================
            excecao_div0:begin
                if (counter == 6'b000000 || counter == 6'b000001) begin
                    state = excecao_div0;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000; ///
                    mux5_s = 3'b001; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b1;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if ( counter == 6'b000010 || counter == 6'b000011 || counter == 6'b000100) begin
                    state = excecao_div0;

                    PC_w = 1'b1;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b100;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000101) begin
                    state = excecao_div0;

                    PC_w = 1'b1;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b001;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b10;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if(counter == 6'b000110) begin
                    state = st_common;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0; 
                    ula_selector = 3'b000; 
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b000;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = 6'b000000;
                end
            end
            //================= sllm =====================
            sllm: begin
                if (counter == 6'b000000) begin
                    state = sllm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001; ///
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b010; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000001 || counter == 6'b000010 || counter == 6'b000011) begin
                    state = sllm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b001;
                    mux1_s = 3'b001; ///
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1; ///
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000100) begin
                    state = sllm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b001;
                    mux1_s = 3'b110; ///
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1; ///
                    temp_b_s = 1'b1; ///
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000101) begin
                    state = sllm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0; 
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b001;
                    mux1_s = 3'b110; ///
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1; ///
                    temp_b_s = 1'b1; ///
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b001; ///
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000110) begin
                    state = sllm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b001;
                    mux1_s = 3'b110;
                    mux2_s = 3'b001; ///
                    mux3_s = 3'b101; ///
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1;
                    temp_b_s = 1'b1;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b001;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000111) begin
                    state = st_common;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b001;
                    mux1_s = 3'b110;
                    mux2_s = 3'b001;
                    mux3_s = 3'b101;
                    mux4_s = 3'b001;
                    mux5_s = 3'b010;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b100;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1;
                    temp_b_s = 1'b1;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000; ///
                    
                    counter = 6'b000000;
                end
            end
            //================= addm =====================
            st_addm: begin
                if (counter == 6'b000000) begin
                    state = st_addm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b000;
                    mux1_s = 3'b000;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001; ///
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b0;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000001 || counter == 6'b000010 || counter == 6'b000011) begin
                    state = st_addm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b000;
                    mux1_s = 3'b101; ///
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b0;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1; ///
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000100) begin
                    state = st_addm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b000;
                    mux1_s = 3'b101;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1; ///
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000101 || counter == 6'b000110 || counter == 6'b000111) begin
                    state = st_addm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b000;
                    mux1_s = 3'b110; ///
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1;
                    temp_b_s = 1'b0;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1; ///
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b001000) begin
                    state = st_addm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b0;
                    ula_selector = 3'b000;
                    mux1_s = 3'b110;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b001;
                    mux5_s = 3'b000;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1;
                    temp_b_s = 1'b1; ///
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b001001) begin
                    state = st_addm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b0;
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1; ///
                    ula_selector = 3'b001; ///
                    mux1_s = 3'b110;
                    mux2_s = 3'b000;
                    mux3_s = 3'b000;
                    mux4_s = 3'b010; ///
                    mux5_s = 3'b100; ///
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1;
                    temp_b_s = 1'b1;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b001010 && Overflow) begin
                    state = excecao_overflow;
                    counter = 6'b000000;
                end
                else if (counter == 6'b001010) begin
                    state = st_addm;

                    PC_w = 1'b0;  
                    memoria_w = 1'b0; 
                    IR_control = 1'b0; 
                    reg_w = 1'b1; ///
                    a_w = 1'b0; 
                    b_w = 1'b0; 
                    ALUOut_w = 1'b1;
                    ula_selector = 3'b001;
                    mux1_s = 3'b110;
                    mux2_s = 3'b010; ///
                    mux3_s = 3'b001; ///
                    mux4_s = 3'b010;
                    mux5_s = 3'b100;
                    mux6_s = 3'b000;
                    mux7_s = 3'b000;
                    mux8_s = 3'b000;
                    mux9_s = 3'b000;
                    mux10_s = 3'b000;
                    mux12_s = 3'b000;
                    mux13_s = 3'b000;
                    mux11_s = 3'b000;
                    mux14_s = 3'b000;
                    reset_out = 1'b0; 
                    temp_a_s = 1'b1;
                    temp_b_s = 1'b1;
                    hi_out_s = 1'b0;
                    lo_out_s = 1'b0;
                    EPC_w = 1'b0;
                    mem_dr_w = 1'b1;
                    load_dec_w = 2'b00;
                    reg_des_shift = 3'b000;
                    
                    counter = counter + 1;
                end
            end
        endcase
    end
end

endmodule