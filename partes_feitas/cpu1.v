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
        wire [31:0] mux1_data_1;
        wire [31:0] mux1_data_2;
        wire [31:0] mux1_data_3;
        wire [31:0] mux1_data_4;
        wire [31:0] mux1_data_5;
        wire [31:0] mux1_data_6;
        // saida
        wire [31:0] mux1_out;

    // mux 2
        // controle 
        wire [2:0] mux2_s;
        // dados
        // saida
        wire [31:0] register_to_write;

    // mux 3
        // controle
        wire [2:0] mux3_s;
        // dados
        wire [4:0] mux3_data_0;
        wire [4:0] ALUOut_out;
        wire [4:0] mux3_data_2;
        wire [4:0] mux3_data_3;
        wire [4:0] mux3_data_4;
        wire [4:0] mux3_data_5;
        wire [4:0] mux3_data_6;
        // saida
        wire [31:0] write_data;

    // mux 4
        // controle
        wire [2:0] mux4_s;
        // dados
        wire [31:0] mux4_data_2;
        // saida
        wire [31:0] out_mux4;

    // mux 5
        // controle
        wire [2:0] mux5_s;
        // dados
        wire [4:0] mux5_data_4;
        // saida
        wire [31:0] out_mux5;

    // mux 13
        // controle
        wire ALUOut_w;

    // unused muxes
        wire [2:0] mux6_s;
        wire [2:0] mux7_s;
        wire [2:0] mux8_s;
        wire [2:0] mux9_s;
        wire [2:0] mux10_s;
        wire [2:0] mux12_s;
        wire temp_a_s;
        wire temp_b_s;
        wire hi_out_s;
        wire lo_out_s;
        wire EPC_w;
        wire mem_dr_w;
        wire load_dec_w;
        wire reg_des_shift;

    // memory mendata
        // controle
        wire memoria_w;
        // dados
        wire memoria_in;
        // saida
        wire memoria_out;

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
        wire [31:0] address_extended;

    // Shift left 2
        // controle
        // dados
        // saida
        wire [31:0] address_shifited;

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
        mux1_data_1,
        mux1_data_2,
        mux1_data_3,
        mux1_data_4,
        mux1_data_5,
        mux1_data_6,
        mux1_out
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
        mux3_data_0,
        ALUOut_out,
        mux3_data_2,
        mux3_data_3,
        mux3_data_4,
        mux3_data_5,
        mux3_data_6,
        write_data
    );

    mux4_3 mux4(
        mux4_s,
        PC_out,
        res_out_a,
        mux4_data_2,
        out_mux4
    );

    mux5_5 mux5(
        mux5_s,
        out_b,
        address_extended,
        address_shifited,
        mux5_data_4,
        out_mux5
    );

    mux13_5 mux13(
        mux13_s,
        S,
        ALUOut_out,
        mux13_data_2,
        mux13_data_3,
        mux13_data_4,
        PC_in
    );

    Memoria memoria(
        mux1_out,
        clk,
        memoria_w,
        memoria_out,
        memoria_in,
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

    Sign_extend_16 se16(
        address,
        address_extended
    );

    shift_left2 sl2(
        address_extended,
        address_shifited
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

    Registrador ALUOut(
        clk,
        reset,
        ALUOut_w,
        S,
        ALUOut_out
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
        mux12_s,
        mux13_s,
        temp_a_s,
        temp_b_s,
        hi_out_s,
        lo_out_s,
        EPC_w,
        mem_dr_w,
        load_dec_w,
        reg_des_shift,
        ALUOut_w,
        reg_w,
        reset
    );

endmodule