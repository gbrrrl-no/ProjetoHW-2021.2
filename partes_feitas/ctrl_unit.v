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
    output reg                reg_des_shift,
    output reg                ALUOut_w,
    output reg                reg_w,


    // special controller for reset instruction
    output reg                reset_out
);

// variables
reg [5:0] counter;
reg [5:0] state;

// parameters
    // main states
    parameter st_common = 16'b00;
    parameter st_reset  = 16'b11;

    // opcode aliases
    parameter addi   = 6'h08;
    parameter addiu  = 6'h09;
    parameter beq    = 6'h04;
    parameter bne    = 6'h05;
    parameter ble    = 6'h06;
    parameter bgt    = 6'h07;
    parameter sllm   = 6'h01;
    parameter lb     = 6'h20;
    parameter lh     = 6'h21;
    parameter lui    = 6'h0F;
    parameter lw     = 6'h23;
    parameter sb     = 6'h28;
    parameter sh     = 6'h29;
    parameter slti   = 6'h0X;
    parameter sw     = 6'h2B;

    //instructions type J
    parameter st_j   = 6'h02;
    parameter st_jal = 6'h03;
    
    //reset
    parameter RESET  = 6'h11;//QUEM SABE ESSE VALOR?

    //funct aliases 17
    parameter fct_over_f = 6'b111111;//deve ser mudado
    parameter fct_add    = 6'h20;
    parameter fct_and    = 6'h24;
    parameter fct_div    = 6'h1A; 
    parameter fct_mult   = 6'h18;
    parameter fct_jr     = 6'h08;
    parameter fct_mfhi   = 6'h10;
    parameter fct_mflo   = 6'h12;
    parameter fct_sll    = 6'h00;//zero
    parameter fct_sllv   = 6'h04;
    parameter fct_slt    = 6'h2A;
    parameter fct_sra    = 6'h03;
    parameter fct_srav   = 6'h07;
    parameter fct_srl    = 6'h02;
    parameter fct_sub    = 6'h22;
    parameter fct_break  = 6'h0D;
    parameter fct_Rte    = 6'h13;
    parameter fct_addm   = 6'h05;     
    
    //excecoes
    parameter excecao_op_ines = 6'h0A;
    parameter excecao_oveflow = 6'h0B;

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
            reg_des_shift = 1'b0;
            
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
            reg_des_shift = 1'b0;
                       
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;                
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
                end         
                else if(counter == 6'b001010) begin
                    case (opcode)
                        st_reset: begin
                            state = st_reset;
                        end
                        st_j:begin
                            state = st_j;
                        end
                        addi:begin
                            state = addi;
                        end
                        addiu:begin
                            state = addiu;
                        end
                        beq:begin
                            state = beq;
                        end
                        ble:begin
                            state = ble;
                        end
                        sllm:begin
                            state = sllm;
                        end
                        lb:begin
                            state = lb;
                        end
                        lh:begin
                            state = lh;
                        end
                        lui:begin
                            state = lui;
                        end
                        lw:begin
                            state = lw;
                        end
                        sb:begin
                            state = sb;
                        end
                        sh:begin
                            state = sh;
                        end
                        slti:begin
                            state = slti;
                        end
                        sw:begin
                            state = sw;
                        end
                        6'b000000: begin
                            case (funct)
                                fct_and: begin
                                    funct = fct_and;
                                end
                                fct_add: begin
                                    funct = fct_add;
                                end
                                fct_jr: begin
                                    funct = fct_jr;
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
                    reg_des_shift = 1'b0;
                    
                    counter = 6'b000000;
                end
            end
            6'b000000: begin//all j instructions
                case (funct)
                    //================= and =======================
                    fct_and: begin
                        if (counter == 6'b000000 || counter == 6'b000001 || counter == 6'b000010) begin
                            state = st_common;
                            
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
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001;   
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
                            reg_des_shift = 1'b0;

                            counter = 6'b000000;   
                        end
                    end
                    //================= add =======================
                    fct_add: begin
                        if (counter == 6'b000000) begin
                            state = st_common;
                            
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
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001;   
                        end
                        else if (counter == 6'b000001 && Overflow) begin
                            state = st_common;
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
                            reg_des_shift = 1'b0;

                            counter = 6'b000000;   
                        end
                    end
                    //================= mult ======================
                    fct_mult: begin
                        if (counter == 6'b000000) begin
                            state = st_common;
                            
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
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001;   
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
                            reg_des_shift = 1'b0;

                            counter = 6'b000000;   
                        end
                    end
                    //================= overflow ==================
                    fct_over_f: begin
                        if (counter == 6'b000000) begin
                            state = st_common;
                            
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
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001;   
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
                            EPC_w = 1'b1;
                            mem_dr_w = 1'b0;
                            load_dec_w = 2'b00;
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001;   
                        end
                        else if (counter == 6'b000010 || counter == 6'b000011 || counter == 6'b000100) begin
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
                            mux1_s = 3'b010;
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
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001;   
                        end
                        else if (counter == 6'b000101) begin
                            state = st_common;
                            
                            memoria_w = 1'b0;
                            IR_control = 1'b0; 
                            reg_w = 1'b1; ///
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
                            mux13_s = 3'b100;
                            mux11_s = 3'b000;
                            mux14_s = 3'b000;  
                            temp_a_s = 1'b0;
                            temp_b_s = 1'b0;
                            hi_out_s = 1'b0;
                            lo_out_s = 1'b0;
                            EPC_w = 1'b0;
                            mem_dr_w = 1'b0;
                            load_dec_w = 2'b00;
                            reg_des_shift = 1'b0;
                            PC_w = 1'b0;

                            counter = 6'b000000;   
                        end
                    end
                    //================= J =========================
                    st_j: begin
                        if (counter == 6'b000000)begin
                            state = st_common;
                            
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
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001; 
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
                            reg_des_shift = 1'b0;

                            counter = 6'b000000; 
                        end
                    end
                    //================= jal ======================= 
                    st_jal: begin
                        if (counter == 6'b000000)begin
                            state = st_common;
                            
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
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001; 
                        end
                        else if (counter == 6'b000001) begin
                            state = st_common;
                            
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
                            reg_des_shift = 1'b0;

                            counter = counter + 6'b000001; 
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
                            reg_des_shift = 1'b0;

                            counter = 6'b000000; 
                        end
                    end
                    //================= jr ========================
                    fct_jr: begin
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
                            reg_des_shift = 1'b0;

                            counter = 6'b000000;
                        end
                    end
                endcase
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001; 
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
                    reg_des_shift = 1'b0;

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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;  
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;    
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;    
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;    
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
                    reg_des_shift = 1'b0;

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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;  
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;    
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;    
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;    
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
                    reg_des_shift = 1'b0;

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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
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
                    ula_selector = 3'b010; ///
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;   
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;
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
                    reg_des_shift = 1'b0;

                    counter = counter + 6'b000001;
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000110) begin
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000110) begin
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
                    counter = counter + 1;
                end
                else if (counter == 6'b000110) begin
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;

                    counter = 6'b000000;   
                end
            end
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
                    counter = 6'b000000;
                end
            end
            excecao_oveflow:begin
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
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
                    reg_des_shift = 1'b0;
                    
                    counter = 6'b000000;
                end
            end
        endcase
    end
end

endmodule