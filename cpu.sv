module cpu(clk, reset, read_data, write_data, mem_addr, mem_cmd,N, V, Z);
    input clk, reset;
    input [15:0] read_data;
    output [15:0] write_data;
    output [1:0] mem_cmd;
    output N, V, Z;
    output [8:0] mem_addr;

    wire[15:0] inst_reg_out, sximm5, sximm8, datapath_out;
    wire[1:0] ALUop, shift, op;
    wire[2:0] readnum, writenum, opcode,nsel;
    wire[3:0] vsel;
    wire loada, loadb,asel, bsel, loadc, loads, write, load_pc, load_addr, reset_pc, addr_sel, load_ir;

    wire [8:0] PC = 9'b0;
    wire [8:0] data_address_out, program_counter_out, program_counter_out2, next_pc;

    vDFF1 #16 InstReg(clk, read_data,load_ir, inst_reg_out);  //Instructino Register, refere to lab 6 document Figure 7 it holds preveous "in" if load is set to 0

    Instruc_decoder InstDec(inst_reg_out, nsel, sximm5, sximm8, ALUop, shift,readnum, writenum, opcode, op); // Instruction Decoder that decodes "in" and wire thoes to datapath

    controler state_machine(clk, reset, opcode, op, vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, load_pc, reset_pc, load_addr, addr_sel, mem_cmd, load_ir);// State machine, refere to lab6 figure 7. it outputs necessart inputs of datapath so that specific instructino is automatically done for us.

    datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, write_data, sximm8, PC, sximm5, Z, N, V, datapath_out); // datapath that outputs data_out and status of the results

    assign program_counter_out2 = program_counter_out + 1'b1;

    assign next_pc = reset_pc ? 9'b000_000_000: program_counter_out2;

    assign mem_addr = addr_sel ? program_counter_out : data_address_out;

    vDFF1 #9 ProgramCounter(clk, next_pc, load_pc, program_counter_out);

    vDFF1 #9 DataAddress(clk, datapath_out[8:0], load_addr, data_address_out);

    assign write_data = datapath_out;
endmodule

module Instruc_decoder(in,nsel,sximm5, sximm8, ALUop, shift, readnum, writenum, opcode, op);
input [15:0] in;
input[2:0] nsel;
output[15:0] sximm5, sximm8;
output[1:0] ALUop, shift, op;
output[2:0] readnum, writenum, opcode;
reg[15:0] sximm8, sximm5;
wire[7:0]extend_8 = ~in[7:0]+1'b1;
wire[4:0]extend_5 =~in[4:0]+1'b1;
assign opcode = in[15:13]; // assigning opcode from "in" to be used in satate machine
assign op = in[12:11];  // assigning op from "in" to be used in state machine

assign ALUop = in[12:11];// decoding "in". this tells datapath which operation in ALU to do.
assign shift = in[4:3];// this tells if we wat to shift number or not

always @(*)begin      //sign extention for sximm8 and sximm 5
    if(in[7]) 
        sximm8 = {{8{1'b1}}, extend_8}; // if 8 bit position of in put is 1 that means sximmm8 is negative number so we want 8 bits of "1"s and in[7:0]
    else
        sximm8 = {{8{1'b0}}, in[7:0]};// if 8 bit position of in put is 1 that means sximmm8 is positive number so we want 8 bits of "0"s and in[7:0]
    
    if(in[4]) 
        sximm5 = {{11{1'b1}}, extend_5}; // if 5 bit position of in put is 1 that means sximmm5 is negative number so we want 11 bits of "1"s and in[4:0]
    else
        sximm5 = {{11{1'b0}}, in[4:0]}; // if 5 bit position of in put is 0 that means sximmm5 is positive number so we want 11 bits of "0"s and in[4:0]
end

//Mux3    Rm when nsel = 100, Rd when nsel = 010, Rn when nsel = 001
 Mux3a mux(in[2:0], in[7:5], in[10:8], nsel, readnum); 

assign writenum = readnum; //according to figure 8 in the lab 6 document we set reanum and write num to the same number

endmodule


//need to update
module controler(clk, reset, opcode, op, vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, load_pc, reset_pc, load_addr, addr_sel, mem_cmd, load_ir);
input clk,  reset;
input[2:0] opcode;
input[1:0] op;
output loada, loadb, loadc, write, asel, bsel, loads, load_pc, reset_pc, load_addr, addr_sel, load_ir;
output[1:0] mem_cmd;
output[2:0] nsel;
output[3:0] vsel;

reg[5:0] ps;
reg[20:0] next;


`define S_rst 5'b00000  // RST state
`define Sd 5'b00001  // decoding state

`define S_m1 5'b00010  // Moving instruction,  writing imediate value to a register. this states write number to specified register

`define S_m2a 5'b00011 // Moving instruction,  copying a value in specified register to other register. this states read number to specified register
`define S_m2b 5'b00100 // Moving instruction,  this state add number.-> 0s + value read from specified register in preveous state
`define S_m2c 5'b00101 // Moving instruction,  this state writes number. write value from specified register to the other specified register

`define S_a1 5'b00110 //Adding and anding instucton. This state read value in one register.
`define S_a2 5'b00111 // this sate reads the value in the other register.
`define S_a3 5'b01000// this staate output operatoin need for ALU.
`define S_a4 5'b01001// this state writes result to a specified register.

`define S_c1 5'b01010//CMP instruction. THis state read a reg to be compared
`define S_c2 5'b01011// this state read a value in the other register to be compared
`define S_c3 5'b01100// this state output necesary inputs for datapth to conpute subtraction and update status.

`define S_mvn1 5'b01101// MVN instruction. THis sate read a value in specied register to be negated.
`define S_mvn2 5'b01110// This state output the necesary inputs to dataph to operate negate operation by ALU.
`define S_mvn3 5'b01111 //This state writes result to specfied register.

`define S_if1 5'b10000 
`define S_if2 5'b10001 
`define S_updatepc 5'b10010

`define S_ldr1 5'b10011 //LDR instructions
`define S_ldr2 5'b10100
`define S_ldr3 5'b10101
`define S_ldr4 5'b10110
`define S_ldr5 5'b10111

`define S_str1 5'b11000 //LDR instructions
`define S_str2 5'b11001
`define S_str3 5'b11010
`define S_str4 5'b11011
`define S_str5 5'b11100

`define S_h 5'b11101

`define MWRITE 2'b00
`define MREAD 2'b01
`define MNONE 2'b10


// next = {vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, load_pc, reset_pc, load_addr, addr_sel mem_cmd, load_ir} //add load_pc, reset_pc, load_addr
//{4'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 3'bx, 1'bx, 1'bx,1'bx, 1'bx,2'bxx, 1'bx  }


always @(posedge clk) begin 
    if(reset)
        ps = `S_rst;
    else begin
    casex ({ps, opcode, op})
        {`S_rst, 3'bx, 2'bx}: ps =`S_if1;//S_rst->S_rst
        {`S_if1, 3'bx, 2'bx}: ps =`S_if2;//S_rst ->Sd
        {`S_if2, 3'bx, 2'bx}: ps =`S_updatepc;//S_rst ->Sd
        {`S_updatepc, 3'bx, 2'bx}: ps =`Sd;//S_rst ->Sd

        {`Sd, 3'b110, 2'b10}: ps =`S_m1;//Sd->S_m1   MOV Rn, #<im8>
        
        {`Sd, 3'b110, 2'b00}: ps =`S_m2a;//Sd -> S_m2a  MOV Rn, Rm{,<sh_op>}
        {`S_m2a, 3'bx, 2'bx}: ps =`S_m2b;
        {`S_m2b, 3'bx, 2'bx}: ps =`S_m2c;////S_m2b ->S_m2c 

        {`Sd, 3'b101, 2'bx0}: ps =`S_a1;// Sd->S_a1ADD Rd, Rn, Rm{,<sh_op>} AND Rd, Rn, Rm{,<sh_op>}
        {`S_a1, 3'bx, 2'bx}: ps =`S_a2;//S_a1 -> S_a2
        {`S_a2, 3'bx, 2'bx}: ps =`S_a3;//S_a2 -> S_a3
        {`S_a3, 3'bx, 2'bx}: ps =`S_a4;//S_a3 -> S_a4


        {`Sd, 3'b101, 2'b01}: ps =`S_c1;//Sd -> S_c1 CMP Rn, Rm{,<sh_op>}
        {`S_c1, 3'bx, 2'bx}: ps =`S_c2; //S_c1 -> S_c2
        {`S_c2, 3'bx, 2'bx}: ps =`S_c3;//S_c2 -> S_c3

        {`Sd, 3'b101, 2'b11}: ps =`S_mvn1;// MVN Rd, Rm{,<sh_op>}Sd->S_mvn1
        {`S_mvn1, 3'bx, 2'bx}: ps =`S_mvn2; //S_mvn1 -> S_mvn2
        {`S_mvn2, 3'bx, 2'bx}: ps =`S_mvn3;//S_mvn2 -> S_mvn3

        {`S_ldr1, 3'b011, 2'b00}: ps = `S_ldr2;//ldr
        {`S_ldr2, 3'bx, 2'bx}: ps = `S_ldr3;
        {`S_ldr3, 3'bx, 2'bx}: ps = `S_ldr4;
        {`S_ldr4, 3'bx, 2'bx}: ps = `S_ldr5;
        
        {`S_str1, 3'b100, 2'b00}: ps = `S_str2;//str
        {`S_str2, 3'bx, 2'bx}: ps = `S_str3;
        {`S_str3, 3'bx, 2'bx}: ps = `S_str4;
        {`S_str4, 3'bx, 2'bx}: ps = `S_str5;

        {`S_h, 3'b111, 2'bx}: ps = `S_h;
    
        default: ps = `S_if1;
    endcase 
    end
end

    always @(*)begin 
//next = {vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, load_pc, reset_pc, load_addr, addr_sel mem_cmd, load_ir} //add load_pc, reset_pc, load_addr
//{4'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 3'bx, 1'bx, 1'bx,1'bx, 1'bx,2'bxx, 1'bx  }

    case(ps)  // WE want "w" to be 1 when in wait state otherwise it should be "0"
        `S_rst: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000,1'b1, 1'b1,1'b0, 1'b0,2'b00, 1'b0};
        `S_if1: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,1'b0, 1'b1, `MNONE, 1'b0};
        `S_if2: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,1'b0, 1'b1, `MNONE, 1'b1};
        `S_updatepc: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 1'b1, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `Sd: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};

        `S_m1:next = { 4'b0100, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 3'b001, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};

        `S_m2a : next = {4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_m2b : next = {4'b0000, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_m2c : next = {4'b0001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 3'b010, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};

        `S_a1 : next = {4'b0000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b001, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_a2 : next = {4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_a3 : next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_a4 : next = {4'b0001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 3'b010, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};

        `S_c1 : next = {4'b0000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b001, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_c2 : next = {4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_c3 : next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 3'b000, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};

        `S_mvn1 : next = {4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_mvn2 : next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
        `S_mvn3 : next = {4'b0001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 3'b010, 1'b0, 1'b0,1'b0, 1'b0,2'b00, 1'b0};
                       // {vsel, loada, loadb,asel, bsel, loadc,loads,write, nsel, load_pc, reset_pc, load_addr, addr_sel mem_cmd, load_ir} 
        `S_ldr1: next = {4'b0000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 1'b0, 1'b0,        1'b0,         1'b0,   2'b00, 1'b0};
        `S_ldr2: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,        1'b0,         1'b0,   2'b00, 1'b0};
        `S_ldr3: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,        1'b1,         1'b0,  `MREAD, 1'b0};
        `S_ldr4: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,         1'b0,        1'b1,  `MREAD, 1'b0};
        `S_ldr5: next = {4'b1000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 3'b010, 1'b0, 1'b0,         1'b0,        1'b1,  `MREAD, 1'b1};
        
                       // {vsel, loada, loadb,asel, bsel, loadc,loads,write, nsel, load_pc, reset_pc, load_addr, addr_sel mem_cmd, load_ir}
        `S_str1: next = {4'b0000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 1'b0, 1'b0,        1'b0,         1'b0,   2'b00, 1'b0};
        `S_str2: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,        1'b0,         1'b0,   2'b00, 1'b0};
        `S_str3: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0,        1'b1,         1'b0,  `MWRITE, 1'b0};
        `S_str4: next = {4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 1'b0, 1'b0,        1'b0,         1'b0,  `MWRITE, 1'b0};
        `S_str5: next = {4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b100, 1'b0, 1'b0,        1'b0,         1'b0,  `MWRITE, 1'b0};

        default: next = 21'b0; 
    endcase
    end

    assign {vsel, loada, loadb,asel, bsel, loadc,loads,write, nsel, load_pc, reset_pc, load_addr, addr_sel, mem_cmd, load_ir} = next;
endmodule

//Multiplexier module, with 3 inputs
module Mux3a( a2, a1, a0, select, b);
    input[2:0] a2, a1, a0, select;
    output[2:0] b;
    reg [2:0] b;

    always @(*) begin 
        case(select) //select is in one-hot code, when it's 100 select a2, 010 select a1, 001 select a0
        3'b100: b = a2;
        3'b010: b = a1;
        3'b001: b = a0;
        default: b = {3{1'bx}};
        endcase
    end
endmodule

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule


module vDFF1(clk, in, load, out);
    parameter n = 9;
    input clk, load;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;

    always_ff @(posedge clk) begin  //compute following at the rise edge of clk
        if(load)                    //only when load is "1" output "in"
            out <= in;
    end

endmodule