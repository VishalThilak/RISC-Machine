module shifter(in, shift, sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;
    reg [15:0] sout;


    always_comb begin //continuously checks "shift" input: specifies what shift operation to do.
        case(shift)
            2'b00: sout = in;        //do not shift and outputs "in" 
            2'b01: sout = in << 1;   //shift input 1 bit to the left and outputs that
            2'b10: sout = in >> 1;   //shift input 1 bit to the right and assign sout[15] = 0 and outputs that
            2'b11: begin
                sout = in >> 1;     //shift input 1 bit to the right and  assign sout[15] = 1 and outputs that
                sout[15] = in[15];
            end
            default: sout = 16'bx;
        endcase
    end


endmodule