module regfile(data_in, writenum, write, readnum, clk, data_out);
    input[15:0] data_in;
    input[2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;
    reg [7:0] select, load;
    wire [15:0] data_store;
    reg[15:0]R0, R1, R2, R3, R4, R5 ,R6 ,R7;
    reg [15:0] data_out;

    //onehot code: address of each register
    `define R0_num 8'b0000_0001
    `define R1_num 8'b0000_0010
    `define R2_num 8'b0000_0100
    `define R3_num 8'b0000_1000
    `define R4_num 8'b0001_0000
    `define R5_num 8'b0010_0000
    `define R6_num 8'b0100_0000
    `define R7_num 8'b1000_0000

    Dec #(3, 8) U1(writenum, load);  //decode writenum -> output "load" which is one-hotcode(specifies which register to write input to)
    Dec #(3, 8) U2(readnum, select); //decode readnum -> output "selsct" which is one-hotcode(specifies which register to read)


    Load_enable S0(clk, write, data_in,load[0], R0); //load_enable: if load is "0" in onehot code and when the clk is pressed store data_in to R0;
    Load_enable S1(clk, write, data_in,load[1], R1); //load_enable: if load is "1" in onehot code and when the clk is pressed store data_in to R1;
    Load_enable S2(clk, write, data_in,load[2], R2); //load_enable: if load is "2" in onehot code and when the clk is pressed store data_in to R2;
    Load_enable S3(clk, write, data_in,load[3], R3); //load_enable: if load is "3" in onehot code and when the clk is pressed store data_in to R3;
    Load_enable S4(clk, write, data_in,load[4], R4); //load_enable: if load is "4" in onehot code and when the clk is pressed store data_in to R4;
    Load_enable S5(clk, write, data_in,load[5], R5); //load_enable: if load is "5" in onehot code and when the clk is pressed store data_in to R5;
    Load_enable S6(clk, write, data_in,load[6], R6); //load_enable: if load is "6" in onehot code and when the clk is pressed store data_in to R6;
    Load_enable S7(clk, write, data_in,load[7], R7); //load_enable: if load is "7" in onehot code and when the clk is pressed store data_in to R7;

    
    //reading file
    always @(*) begin // continuously checks "select"(onehot code of readnum): outputs value stored in specified register
            case(select)
                `R0_num:data_out = R0;
                `R1_num:data_out = R1;
                `R2_num:data_out = R2;
                `R3_num:data_out = R3;
                `R4_num:data_out = R4;
                `R5_num:data_out = R5;
                `R6_num:data_out = R6;
                `R7_num:data_out = R7;
                default: data_out = 16'bx;
            endcase
    end
endmodule

//Load_enable module
module Load_enable(clk,write,in,load,out);
  input clk, write, load;
  input [15:0] in;
  output [15:0] out;
  reg [15:0] out;


  always_ff @(posedge clk)
    if(write & load)      // only at the rise of clk and write/load is "1", assign value of "in" to "out"
        out <= in;
endmodule


//Decoder module(parametrized, 2->4 decoder)
module Dec(a, b);
    parameter n = 2;
    parameter m = 4;
    input [n-1:0] a;
    output [m-1:0] b;
   
    wire [m-1:0] b = 1 << a;
endmodule