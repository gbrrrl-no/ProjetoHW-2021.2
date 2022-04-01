module cpu_add (
    input wire clk,
    input wire reset
);

// Control wires

    wire PC_w;
    wire MEM_w;
    wire IR_w;

// Data wires

    wire [31:0] ULA_out;
    wire [31:0] PC_out;
    wire [31:0] MEM_to_IR;
    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;

    Registrador PC_(
        clk,
        reset,
        PC_w,
        ULA_out,
        PC_out
    );

    Memoria MEM_(
        PC_out,
        clk,
        MEM_w,
        ULA_out,
        MEM_to_IR
    );

    Instr_Reg IR_(
        clk,
        reset,
        IR_w,
        MEM_to_IR,
        OPCODE,
        RS,
        RT,
        OFFSET
    );

    mux_3_8 M_WREG_(

    );

    // Banco_reg 
    
endmodule