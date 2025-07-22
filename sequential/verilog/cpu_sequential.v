`timescale 1ns/1ps

`include "modules/alu.v"
`include "modules/program_counter.v"
`include "modules/instruction_memory.v"
`include "modules/register_file.v"
`include "modules/data_memory.v"
`include "modules/control_unit.v"

module cpu_sequential(
    input clk,                  
    input reset                 
);
    // program counter
    wire [63:0] pc_next;        
    wire [63:0] pc_current;     
    
    // for branch instruction
    wire [63:0] branch_target;
    wire branch_taken;
    
    // comes from instruction fetch
    wire [31:0] instruction;    
    
    // control signals - will tell CPU what to do
    wire mem_read;              // read from memory
    wire mem_write;             // write in memory
    wire mem_to_reg;            // value of ALU from memory
    wire reg_write;             // stores value in register
    wire branch;                // branch instruction there or not
    wire alu_src;               
    
    // register file signals
    wire [4:0] rs1;            // sourcereg
    wire [4:0] rs2;            // sourcereg
    wire [4:0] rd;             // destination regi
    wire signed [63:0] reg_write_data;    
    wire signed [63:0] reg_read_data1;    
    wire signed [63:0] reg_read_data2;    
    
    // ALU ke signals
    wire signed [63:0] alu_result;     // ALU final answer
    wire signed [63:0] alu_operand2;   // ALU second input (reg's immediate value)
    wire zero;                        // ALU's zero flag
    
    // memory signals
    wire signed [63:0] mem_read_data;

    // Program Counter - tracks instruction address
    program_counter pc(
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),      // next instruction address
        .pc(pc_current)         // current instruction address
    );

    // program instructions storing
    instruction_memory imem( // REMEMBER INITIALIZED AS imem, so you can do cpu.imem.memory[0] in testbench
        .pc(pc_current),         // from current PC 
        .instruction(instruction) // get instruction 
    );

    control_unit ctrl(
        .instruction(instruction),  // instruction decode 
        .branch(branch),            // branch instruction there or not
        .mem_read(mem_read),        // read from memory
        .mem_to_reg(mem_to_reg),    
        .mem_write(mem_write),      // write in memory
        .alu_src(alu_src),          
        .reg_write(reg_write)      
    );

    // Register File ke inputs set karo
    assign rs1 = instruction[19:15];  // source register 1 
    assign rs2 = instruction[24:20];  // source register 2 
    assign rd = instruction[11:7];    // destination register

    // Register File
    register_file reg_file(
        .clk(clk),
        .rs1(rs1),                    // first source register
        .rs2(rs2),                    // second source register
        .rd(rd),                      // destination register
        .write_data(reg_write_data),  // value to be written
        .reg_write(reg_write),        // write enable signal
        .read_data1(reg_read_data1),  // first register's value
        .read_data2(reg_read_data2)   // second register's value
    );

    // ALU's second operand selection 
    wire [63:0] temp;
    assign temp = (instruction[6:0]==7'b0010011 || instruction[6:0]==7'b0000011) ? {{53{instruction[31]}}, instruction[30:20]} : {{53{instruction[31]}},{instruction[30:25]},{instruction[11:7]}};
    assign alu_operand2 = alu_src ? temp : reg_read_data2;  // immediate's register value
    
    // ALU - actual calculation
    alu main_alu(
        .instruction(instruction),     // instruction decode 
        .in1(reg_read_data1),         // 1st operand
        .in2(alu_operand2),           // 2nd operand
        .out(alu_result),            // result
        .zero(zero)
    );

    // PC update
    assign branch_target = pc_current + {{51{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // calculate branch target
    assign branch_taken = branch & zero;                    // branch should be taken or not?
    assign pc_next = branch_taken ? branch_target : pc_current + 4;                       // next PC set 

    // Data Memory - data storing
    data_memory dmem( // REMEMBER INITIALIZED AS dmem, so you can do cpu.dmem.memory[0] in testbench
        .clk(clk),
        .address(alu_result),         // memory address
        .write_data(reg_read_data2),  // data to be written
        .mem_read(mem_read),          // read signal
        .mem_write(mem_write),        // write signal
        .read_data(mem_read_data)    
    );

    assign reg_write_data = mem_to_reg ? mem_read_data : alu_result;

endmodule
