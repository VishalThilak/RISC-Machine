 module ALU(Ain, Bin, ALUop, out, Z);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output[2:0] Z;
    reg[2:0] Z;
    reg [15:0] out, add, sub;
    reg[1:0] ovf;//first bit for sub, second bit for add

    OVF check_ovf_1(Ain, Bin, 1'b0, add, ovf[0]); //add
    OVF check_ovf_2(Ain, Bin, 1'b1, sub, ovf[1]); //sub

    always_comb begin  //continuously checks ALUop input. Specifies which ALU operation to do
        case(ALUop)
            2'b00: out = add;  //addition
            2'b01: out = sub;  //subtraction
            2'b10: out = Ain & Bin;  //logical operation "&"
            2'b11: out = ~Bin;       //logical operation "~" 
            default: out = 16'bx;
        endcase

        if(out == 16'b0 )begin// Z becomes 1 if out equals 16'b0
            if(ALUop == 2'b00) //if add
                Z = {1'b1, out[15], ovf[0]}; 
            else if(ALUop == 2'b01) //if sub
                Z = {1'b1, out[15], ovf[1]};
            else
                Z = {1'b1, out[15], 1'b0};
        end
        else begin  // Z becomes 0 if out is not equals 16'b0
            if(ALUop == 2'b00) //if add
                Z = {1'b0, out[15], ovf[0]}; // Z becomes 1 if out equals 16'b0
            else if(ALUop == 2'b01) //if sub
                Z = {1'b0, out[15], ovf[1]};
            else
                Z = {1'b0, out[15], 1'b0};
        end 
    end
endmodule

// add a + b or subtract a- b, check for overflow
module OVF(a,b,sub,s,ovf); //referece from slide set 10
    input [15:0] a,b;
    input sub; //subtract if sub = 1, otherwise add
    output [15:0] s;
    output ovf; //1 if overflow
    wire c1, c2; //carry out last 2 bits
    wire ovf = c1 ^ c2; //overflow if signs don't match

    Adder1 #15 ai(a[14:0], b[14:0]^{15{sub}}, sub, c1,s[14:0]); //non sign bits
    Adder1 #1  as(a[15], b[15]^sub, c1, c2, s[15]); //add sign bits
endmodule

//multi-bit adder
module Adder1(a,b, cin, count,s); //referece from slide set 10
    parameter n = 16;
    input [n-1:0] a,b;
    input cin;
    output [n-1:0] s;
    output count;
    wire [n-1:0] s;
    wire count;

    assign {count, s} = a+b+cin;
endmodule