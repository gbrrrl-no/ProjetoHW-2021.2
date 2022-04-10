module cpu1 (
    input wire clk,
    input wire reset
);
    
    // PC
        // controle
        wire PC_w;
        // dados
        wire [31:0] PC_in;
        // saida
        wire [31:0] PC_out;

    // mux 1
        // controle
        wire [2:0] mux1_s;
        // dados
        wire [31:0] mux1_data_2;
        wire [31:0] mux1_data_3;
        wire [31:0] mux1_data_4;
        // saida
        wire [31:0] out_mux1;

    // mux 2
        // controle 
        wire [2:0] mux2_s;
        // dados
        // saida
        wire [4:0] register_to_write;

    // mux 3
        // controle
        wire [2:0] mux3_s;
        // dados
        wire [31:0] mux3_data_0;
        wire [31:0] ALUOut_out;
        // saida
        wire [31:0] write_data;

    // mux 4
        // controle
        wire [2:0] mux4_s;
        // saida
        wire [31:0] out_mux4;

    // mux 5
        // controle
        wire [2:0] mux5_s;
        // saida
        wire [31:0] out_mux5;

    // mux 6
        // controle
        wire [2:0] mux6_s;
        // saida
        wire [31:0] out_mux6;

    // mux 7
        // controle
        wire [2:0] mux7_s;
        // saida
        wire [31:0] out_mux7;

    // mux 8
        // controle
        wire [2:0] mux8_s;
        // saida
        wire [4:0] N;

    // mux 9
        // controle
        wire [2:0] mux9_s;
        // saida
        wire [31:0] out_mux9;

    // mux 10
         
        wire [2:0] mux10_s;

    // mux 11
         
        wire [2:0] mux11_s;
        wire [31:0] mux11_data_0;
        wire [31:0] mux11_data_1;
        wire [31:0] out_mux11;

    // mux 12
         
        wire [2:0] mux12_s;
        wire [31:0] out_mux12;

    // mux 13
        // controle
        wire [2:0] mux13_s;
        wire [31:0] mux13_data_2;
        wire [31:0] out_mux14;
        
    // mux 14
        // controle
        wire [2:0] mux14_s;
        wire [31:0] mux14_data_0;
        wire [31:0] mux14_data_1;

    // unused
        wire [2:0] reg_des_shift;
    
    // Sh e Sb
       
        wire [31:0] sb_out;
        wire [31:0] sh_out;

    // memory mendata
        // controle
        wire memoria_w;
        // dados
        wire [31:0] memoria_in;
        // saida
        wire [31:0] memoria_out;

    // Memory dada register

        wire mdr_w;
        wire [31:0] mdr_out;
    
    // Temp a e b

        wire temp_a_s;
        wire temp_b_s;        
        wire [31:0] temp_a_out;
        wire [31:0] temp_b_out;

    // low e high out

        wire hi_out_s;
        wire lo_out_s;        
        wire [31:0] hi_out_out;
        wire [31:0] lo_out_out;

    // mult e div

        wire start_mult;
        wire stop_mult;
        wire start_div;
        wire stop_div;
        

    //Epc

        wire EPC_w;
        wire [31:0] EPC_out;

    // ir
        // controle 
        wire IR_control; 
        // dados

    // saida
        wire [31:26] opcode;
        wire [25:21] rs;
        wire [20:16] rt;
        wire [15:0]  address; 

    // Banco de registradores 
        // controle 
        // dados
        // saida
        wire [31:0] res_out_a;
        wire [31:0] res_out_b;
        wire reg_w;
        wire ALUOut_w;

    // Registror de deslocamento

        wire [31:0] r_desloc_out;

    // Reg A 
        // controle
        wire a_w;
        // saida
        wire [31:0] out_a;

    // Reg A 
        // controle
        wire b_w;
        // saida
        wire [31:0] out_b;

    // Sign_extend
        // controle
        // dados
        // saida
        wire [31:0] sign_extended1;
        wire [31:0] sign_extended2;
        wire [31:0] sign_extended3;
        wire [31:0] sign_extended4;
        wire [31:0] sign_extended5;
        wire [31:0] sign_extended6;
        wire [31:0] sign_extended7;

    // Shift left 2
        // controle
        // dados
        // saida
        wire [31:0] address_shifited;
        wire [31:0] out_shift;

    // ula
        // controle
        wire [2:0] ula_selector;
        // saidas   
        wire [31:0] S;
        wire Overflow;
        wire Negativo;
        wire Zero;
        wire Igual;
        wire Maior;
        wire Menor;

    // load decider
        wire [1:0] load_des_s;
        wire [31:0] load_decider_out;

    //registrador de deslocamento
        wire [31:0] address_extended;



    Registrador PC_(
        clk,
        reset,
        PC_w,
        PC_in,
        PC_out
    );

    mux1_7 mux1(
        mux1_s,
        PC_out,
        ALUOut_out,
        mux1_data_2,
        mux1_data_3,
        mux1_data_4,
        out_a,
        out_b,
        out_mux1
    );

    mux2_5 mux2(
        mux2_s,
        rs,
        rt,
        address[15:11], // tem que ver se isso funciona mesmo
        register_to_write
    );

    mux3_8 mux3(
        mux3_s,
        load_decider_out,
        ALUOut_out,
        hi_out_out,
        lo_out_out,
        out_mux12,
        r_desloc_out,
        sign_extended7,
        write_data
    );

    mux4_3 mux4(
        mux4_s,
        PC_out,
        out_a,
        temp_a_out,
        out_mux4
    );

    mux5_5 mux5(
        mux5_s,
        out_b,
        sign_extended1,
        address_shifited,
        temp_b_out,
        out_mux5
    );

    mux6_2 mux6(
        mux6_s,
        out_a,
        out_b,
        out_mux6
    );

    mux7_2 mux7(
        mux7_s,
        out_a,
        out_b,
        out_mux7
    );

    mux8_4 mux8(
        mux8_s,
        out_b[4:0],
        address[10:6],
        mdr_out[4:0],
        N
    );

    mux9_3 mux9(
        mux9_s,
        out_a,
        sign_extended1,
        out_b,
        out_shift,
        out_mux9
    );
    
    mux10_5 mux10(
        mux10_s,
        sb_out,
        sh_out,
        out_b,
        sign_extended2,
        sign_extended4,
        memoria_in
    );

    mux11_2 mux11(
        mux11_s,
        mux11_data_0,
        mux11_data_1,
        out_mux11
    );

    mux12_2 mux12(
        mux12_s,
        sign_extended3,
        sign_extended5,
        out_mux12
    );

    wire [24:0] sf2_25_out;
    shift_left2_25 sf2_25(
        {rs,rt,address},
        sf2_25_out
    );

    assign mux13_data_2 = {PC_out[31:28],sf2_25_out};

    mux13_5 mux13(
        mux13_s,
        S,
        ALUOut_out,
        mux13_data_2,
        EPC_out,
        sign_extended6,
        PC_in
    );

    mux14_2 mux14(
        mux14_s,
        mux14_data_0,
        mux14_data_1,
        out_mux14
    );

    SB sb(
        out_b[7:0],
        mdr_out[31:8],
        sb_out
    );

    SH sh(
        out_b[15:0],
        mdr_out[31:16],
        sh_out
    );

    Memoria memoria(
        out_mux1,
        clk,
        memoria_w,
        memoria_in,
        memoria_out
    );

    Registrador mem_d_r(
        clk,
        reset,
        mdr_w,
        memoria_out,
        mdr_out
    );

    load_decider load_des(
        clk,
        load_des_s,
        mdr_out,
        load_decider_out
    );

    Registrador hi_out(
        clk,
        reset,
        hi_out_s,
        out_mux11,
        hi_out_out
    );

    Registrador lo_out(
        clk,
        reset,
        lo_out_s,
        out_mux14,
        lo_out_out
    );

    Registrador temp_a(
        clk,
        reset,
        temp_a_s,
        mdr_out,
        temp_a_out
    );
    
    Registrador temp_b(
        clk,
        reset,
        temp_b_s,
        mdr_out,
        temp_b_out
    );

    Registrador epc(
        clk,
        reset,
        EPC_w,
        ALUOut_out,
        EPC_out
    );


    Instr_Reg IR(
        clk,
        reset,
        IR_control,
        memoria_out,
        opcode,
        rs,
        rt,
        address
    );

    Banco_reg register(
        clk,
        reset,
        reg_w,
        rs,
        rt,
        register_to_write,
        write_data,
        res_out_a,
        res_out_b
    );

    Registrador A(
        clk,
        reset,
        a_w,
        res_out_a,
        out_a
    );

    Registrador B(
        clk,
        reset,
        b_w,
        res_out_b,
        out_b
    );

    Sign_extend_16 se16_1(
        address,
        sign_extended1
    );

    Sign_extend_16 se16_2(
        out_b[15:0],
        sign_extended2
    );

    Sign_extend_16 se16_3(
        mdr_out[15:0],
        sign_extended3
    );

    Sign_extend_8 se8_1(
        out_b[7:0],
        sign_extended4
    );

    Sign_extend_8 se8_2(
        mdr_out[7:0],
        sign_extended5
    );

    Sign_extend_8 se1_1(
        memoria_out[7:0],
        sign_extended6
    );

    Sign_extend_1 se1_2(
        Menor,
        sign_extended7
    );

    shift_left2 sl2(
        sign_extended1,
        address_shifited
    );

    shift_left16 sl3(
        sign_extended1,
        out_shift
    );

    ula32 ula(
        out_mux4,
        out_mux5,
        ula_selector,
        S,
        Overflow,
        Negativo,
        Zero,
        Igual,
        Maior,
        Menor
    );

    RegDesloc r_desloc(
        clk,
        reset,
        reg_des_shift,
        N,
        out_mux9,
        r_desloc_out
    );

    Registrador ALUOut(
        clk,
        reset,
        ALUOut_w,
        S,
        ALUOut_out
    );

    mult Multiplicador(
        clk,
        reset,
        out_mux6,
        out_b,
        start_mult,
        stop_mult,
        mux11_data_0,
        mux14_data_0
    );

    div Divisor(
        clk,
        reset,
        out_mux7,
        out_b,
        start_div,
        stop_div,
        mux11_data_1,
        mux14_data_1
    );

    ctrl_unit CTRL_(
        clk,
        reset,
        Overflow,
        Negativo,
        Zero,
        Igual,
        Maior,
        Menor,
        stop_mult,
        address[5:0],
        opcode,
        PC_w,
        memoria_w,
        IR_control,
        a_w,
        b_w,
        ula_selector,
        mux1_s,
        mux2_s,
        mux3_s,
        mux4_s,
        mux5_s,
        mux6_s,
        mux7_s,
        mux8_s,
        mux9_s,
        mux10_s,
        mux11_s,
        mux12_s,
        mux13_s,
        mux14_s,
        temp_a_s,
        temp_b_s,
        hi_out_s,
        lo_out_s,
        start_mult,
        EPC_w,
        mdr_w,
        load_des_s,
        reg_des_shift,
        ALUOut_w,
        reg_w,
        reset
    );

endmodule