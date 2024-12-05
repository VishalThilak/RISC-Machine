//need to update
module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata,sximm8, PC, sximm5, Z_out,N, V, datapath_out);

input clk, loada, loadb, asel, bsel, loadc, loads, write;
input [2:0] readnum, writenum;
input [1:0] shift, ALUop;
input [3:0] vsel;
input [15:0] mdata, sximm8, sximm5;
input [8:0] PC; 
//changed PC to 9 bits and input in mux9 is 7'b0 instead of 8'b0
output Z_out, N, V;
output [15:0] datapath_out;

wire[15:0] data_in, data_out,data_in_6,data_in_8, Ain, sout, Bin, out, data_out_from_C;
wire[2:0] Z_from_alu, status;

//multiplexier #9 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document modified to Figure 5 in lab 6 document
Mux4a mux9(mdata, sximm8, {7'b0, PC}, data_out_from_C, vsel, data_in);

//register file #1 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);

//load_enable #3 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
vDFF1 #16 load_enableA(clk, data_out, loada, data_in_6);

//load_enable #4 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
vDFF1 #16 load_enableB(clk, data_out, loadb, data_in_8);

//multiplexier #6 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
Mux2a mux6(16'b0, data_in_6, asel, Ain);

//shifter #8 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
shifter shifts(data_in_8, shift, sout);

//multiplexier #7 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
Mux2a mux7(sximm5, sout, bsel, Bin);

//ALU #2 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
ALU U2(Ain, Bin, ALUop, out, Z_from_alu);

//load_enable #5 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
vDFF1 #16 load_enableC(clk, out, loadc, data_out_from_C);

//load_enable #10 in Figure 1: “Simple RISC Machine” Datapath in lab_5 document
vDFF1 #3 load_enablestatus(clk, Z_from_alu, loads, {Z_out, N, V});

assign datapath_out = data_out_from_C;    //assigning output of load_enableC to datapath_out 

endmodule

//Multiplexier module. outputs a1 when select is "1" and outputs a0 when select is "0"
module Mux2a(input[15:0] a1, input[15:0] a0, input select, output[15:0] b);
    assign b = select ? a1: a0;
endmodule

//Multiplexier module, with 4 inputs
module Mux4a(a3, a2, a1, a0, select, b);
    input[15:0]a3, a2, a1, a0;
    input[3:0] select;
    output[15:0] b;
    reg[15:0] b;
    always @(*) begin 
        case(select) //select is in one-hot code, when it's 1000 select a3, 0100 select a2, 0010 select a1, 00001 select a0
        4'b1000: b = a3;
        4'b0100: b = a2;
        4'b0010: b = a1;
        4'b0001: b = a0;
        default: b = {16{1'bx}};
        endcase
    end
endmodule


//Load_enable module for datapath **it is not the same as load_enable module in regfile.sv**
module vDFF1(clk, in, load, out);
    parameter n = 1;
    input clk, load;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;

    always_ff @(posedge clk) begin  //compute following at the rise edge of clk
        if(load)                    //only when load is "1" output "in"
            out <= in;
    end

endmodule