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

    //special controller for reset instruction
    output reg                res_out,
);

endmodule