module cpu_tb();
reg clk, s, load, err, reset;
reg [15:0] in;

wire Z, N, V;
wire [15:0] out;

cpu DUT(clk, reset, s, load, in, out, N, V, Z, w);

`define Sw 4'b0000
`define Sd 4'b0001

`define S_m1 4'b0010

`define S_m2a 4'b0011
`define S_m2b 4'b0100
`define S_m2c 4'b0101

`define S_a1 4'b0110
`define S_a2 4'b0111
`define S_a3 4'b1000
`define S_a4 4'b1001

`define S_c1 4'b1010
`define S_c2 4'b1011
`define S_c3 4'b1100

`define S_mvn1 4'b1101
`define S_mvn2 4'b1110
`define S_mvn3 4'b1111


initial begin// clk alternates every 5 unit
    clk = 1'b0; #5; err = 1'b0;

    forever begin
        clk = 1'b1; #5;
        clk = 1'b0; #5;
    end
end

initial begin

    /////////////////////////////////////checking Instrction register//////////////////////////////////////////////////////////
    // this section checkis if Instructino regiaster holds preveous input when load is set to 0 and checks if it updates output to current input when load is set to "1"
    #10;
    load = 1'b1; in = 16'b0000_0000_0000_0111;
    #10;

    //Since load is set to 1, we expect to see the same value from output as input.
    if(DUT.inst_reg_out !=  16'b 0000_0000_0000_0111)begin
            $display("ERROR ** output is %b, expected %b", DUT.inst_reg_out , 16'b 0000_0000_0000_0111);
            err = 1'b1;
    end

    
    load = 1'b0; in = 16'b0000_0000_1111_1111;
    #10;
//Since load is set to 0, we expect to see preveous input
    if(DUT.inst_reg_out !=  16'b 0000_0000_0000_0111)begin
            $display("ERROR ** output is %b, expected %b", DUT.inst_reg_out , 16'b 0000_0000_0000_0111);
            err = 1'b1;
    end

    
    load = 1'b1; in = 16'b0000_0000_1111_1111;
    #10;
//Since load is set to 1, we expect to see the same value from output as input.
    if(DUT.inst_reg_out !=  16'b0000_0000_1111_1111)begin
            $display("ERROR ** output is %b, expected %b", DUT.inst_reg_out , 16'b0000_0000_1111_1111);
            err = 1'b1;
    end



    /////////////////////////////////////checking Instruction Decoder//////////////////////////////////////////////////////////
    // This section checks if decoding "in" outputs the right code to be used by datapath
    load = 1'b1; in = 16'b1101_0000_1100_0111;     
    #10;

    //sximm5, sximm8, ALUop, shift,readnum, writenum, opcode, op
    $display("checking value in sximm5");
    if(DUT.sximm5 !=  16'b0000_0000_0000_0111)begin
            $display("ERROR ** output is %b, expected %b", DUT.sximm5 , 16'b0000_0000_0000_0111);
            err = 1'b1;
    end
    $display("checking value in sximm8");
    if(DUT.sximm8 !=  16'b1111_1111_0011_1001)begin
            $display("ERROR ** output is %b, expected %b", DUT.sximm8 , 16'b1111_1111_0011_1001);
            err = 1'b1;
    end
    $display("checking value in ALUop");
    if(DUT.ALUop !=  2'b10)begin
            $display("ERROR ** output is %b, expected %b", DUT.ALUop , 16'b0000_0000_0000_0111);
            err = 1'b1;
    end
    $display("checking value in shift");
    if(DUT.shift !=  2'b00)begin
            $display("ERROR ** output is %b, expected %b", DUT.shift , 2'b00);
            err = 1'b1;
    end
    $display("checking value in opcode");
    if(DUT.opcode != 3'b110)begin
            $display("ERROR ** output is %b, expected %b", DUT.opcode , 3'b110);
            err = 1'b1;
    end
    $display("checking value in op");
    if(DUT.op !=  2'b10)begin
            $display("ERROR ** output is %b, expected %b", DUT.op , 2'b10);
            err = 1'b1;
    end

    load = 1'b1; in = 16'b1101_0000_0001_0111;     ///MOV R0 #7
    #10;

    //checking sign extention for sximm5 when its negative
    $display("checking value in sximm5");
    if(DUT.sximm5 !=  16'b1111_1111_1110_1001)begin
            $display("ERROR ** output is %b, expected %b", DUT.sximm5 , 16'b0000_0000_0000_0111);
            err = 1'b1;
    end





    /////////////////////////////////////testing State_machine///////////////////////////////////////////////////////////////////
    //This section test state machine and output of cpu.
    //WE are testing if the state transition is correct and output is also correct

////////////////////////////////////////////////MOV R0, #7///////////////////////////////////////////////////////////////////////////
//We move 7 to R0
    #10;
    load = 1'b1; in =16'b1101_0000_0000_0111; reset = 1'b1; 
    //checking if ps is in the wait state_machine
    $display("checking value in ps");
    if(w !=  1'b1)begin
            $display("ERROR ** output is %b, expected %b", w , 1'b1);
            err = 1'b1;
    end
    s = 1'b1; reset = 1'b0;
    #10
    //ps should be in Decode state_machine
    $display("checking ps. should be in Wait state_machine");
    if(DUT.state_machine.ps !=  4'b0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0001);
            err = 1'b1;
    end
    
    #10;
    //ps should be S_m1 state_machine which writes num in specified register in regfile(memory)
    $display("checking value in ps");
    if(DUT.state_machine.ps !=  4'b0010)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0010);
            err = 1'b1;
    end

    #10;
    //ps should be in wait state_machine as the operation is finished
    $display("checking value in ps");
    if(DUT.state_machine.ps !=  4'b0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0000);
            err = 1'b1;
    end
    $display("checking value in R0");
    if(DUT.DP.REGFILE.R0 !=  16'b0000_0000_0000_0111)begin
            $display("ERROR ** output is %b, expected %b", DUT.DP.REGFILE.R0 , 16'b0000_0000_0000_0111);
            err = 1'b1;
    end



    ///////////////////////////////////////////MOV R1, #5////////////////////////////////////////////////////////////////////////////////////////////////////
    //We move 5 to R1
    load = 1'b1; in =16'b1101_0001_0000_0101; reset = 1'b1; 
    #10;
    //checking if ps is in the wait state_machine
    $display("checking value in ps");
    if(w != 1'b1)begin
            $display("ERROR ** output is %b, expected %b", w , 1'b1);
            err = 1'b1;
    end

    s = 1'b1; reset = 1'b0;
    #10

    //ps should be in Decode state_machine
    $display("checking ps should be in Decode state_machine");
    if(DUT.state_machine.ps !=  4'b0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0001);
            err = 1'b1;
    end
    
    #10;
    //ps should be S_m1 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_m1");
    if(DUT.state_machine.ps !=  4'b0010)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0010);
            err = 1'b1;
    end

    #10;
    //ps should be in wait state_machine
    $display("ps should be in wait state_machine");
    if(DUT.state_machine.ps !=  4'b0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0000);
            err = 1'b1;
    end
    $display("checking value in R1");
    if(DUT.DP.REGFILE.R1 !=  16'b0000_0000_0000_0101)begin
            $display("ERROR ** output is %b, expected %b", DUT.DP.REGFILE.R1 , 16'b0000_0000_0000_0101);
            err = 1'b1;
    end


    load = 1'b1; in =16'b1101_0001_0000_0101; reset = 1'b1; 
    #10;
    //checking if ps is in the wait state_machine
    $display("checking value in ps");
    if(DUT.state_machine.ps !=  4'b0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0000);
            err = 1'b1;
    end
///////MOV R2, R0/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// We copy value in R0 to R2
//We hope to see at the end R2 has a value of 7 

load = 1'b1; in =16'b1100_0000_0100_0000; reset = 1'b1; 
#10;
//checking if ps is in the wait state_machine
    $display("checking value in ps");
    if(w != 1'b1)begin
            $display("ERROR ** output is %b, expected %b", w , 1'b1);
            err = 1'b1;
    end

    s = 1'b1; reset = 1'b0;
    #10

    //ps should be in Decode state_machine
    $display("checking ps should be in Decode state_machine");
    if(DUT.state_machine.ps !=  4'b0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0001);
            err = 1'b1;
    end
    
    #10;
    //S_m2a
    $display("ps shold be S_m2a");
    if(DUT.state_machine.ps != `S_m2a) begin
        $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_m2a);
            err = 1'b1;
    end
    #10;
    //S_m2b
    $display("ps shold be S_m2b");
    if(DUT.state_machine.ps != `S_m2b) begin
        $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_m2b);
            err = 1'b1;
    end
    #10;
        //S_m2c
    $display("ps shold be S_m2c");
    if(DUT.state_machine.ps != `S_m2c) begin
        $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_m2c);
            err = 1'b1;
    end
    #10;

    //ps should be in wait state_machine
    $display("ps should be in wait state_machine");
    if(DUT.state_machine.ps !=  4'b0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0000);
            err = 1'b1;
    end
    $display("checking value in R0");
    if(DUT.DP.REGFILE.R0 !=  16'b0000_0000_0000_0111)begin
            $display("ERROR ** output is %b, expected %b", DUT.DP.REGFILE.R1 , 16'b0000_0000_0000_0111);
            err = 1'b1;
    end


    

   

/////////////////////////////////////////////////////ADD R3, R0, R1  :R3 = 7+5 = 12/////////////////////////////////////////////////////////////////
//For this section we test Add instruction
//WE must see R3 having 12 at the end
    load = 1'b1; in =16'b1010_0000_0110_0001; reset = 1'b1; 
    #10;
    //checking if ps is in the wait state_machine
    $display("checking value in ps");
    if(w != 1'b1)begin
            $display("ERROR ** output is %b, expected %b", w , 1'b1);
            err = 1'b1;
    end

    s = 1'b1; reset = 1'b0;
    #10

    //ps should be in Decode state_machine
    $display("checking ps should be in Decode state_machine");
    if(DUT.state_machine.ps !=  4'b0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0001);
            err = 1'b1;
    end
    
    #10;
    //ps should be S_a1 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a1");
    if(DUT.state_machine.ps !=  `S_a1)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_a1);
            err = 1'b1;
    end

    #10;
    //ps should be S_a2 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a2");
    if(DUT.state_machine.ps !=  `S_a2)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_a2);
            err = 1'b1;
    end

    #10;
    //ps should be S_a3 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a3");
    if(DUT.state_machine.ps !=  `S_a3)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_a3);
            err = 1'b1;
    end
    
    #10;
    //ps should be S_a1 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a4");
    if(DUT.state_machine.ps !=  `S_a4)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_a4);
            err = 1'b1;
    end

    #10;
    //ps should be in wait state_machine
    $display("ps should be in wait state_machine");
    if(DUT.state_machine.ps !=  4'b0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0000);
            err = 1'b1;
    end
    $display("checking value in R3");
    if(DUT.DP.REGFILE.R3 !=  16'b0000_0000_0000_1100)begin
            $display("ERROR ** output is %b, expected %b", DUT.DP.REGFILE.R3 , 16'b0000_0000_0000_1100);
            err = 1'b1;
    end

//     ////////////////////////////////////////////////////////////////CMP R1, R0 5 -7 = -2/////////////////////////////////////////////////////////////////////
//This section test CMP operatino
//We compair R1 and R0 by subtractiong R0 from R1 . WE update status. this is the only instruction we update status.
        
load = 1'b1; in =16'b1010_1001_0000_0000; reset = 1'b1; 
    #10;
    //checking if ps is in the wait state_machine
    $display("checking value in ps");
    if(w != 1'b1)begin
            $display("ERROR ** output is %b, expected %b", w , 1'b1);
            err = 1'b1;
    end

    s = 1'b1; reset = 1'b0;
    #10

    //ps should be in Decode state_machine
    $display("checking ps should be in Decode state_machine");
    if(DUT.state_machine.ps !=  4'b0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0001);
            err = 1'b1;
    end
    #10;

    //S_c1
    $display("ps shold be S_c1");
    if(DUT.state_machine.ps != `S_c1) begin
        $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_c1);
            err = 1'b1;
    end
    #10;

    //S_c2
    $display("ps shold be S_c2");
    if(DUT.state_machine.ps != `S_c2) begin
        $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_c2);
            err = 1'b1;
    end
    #10;
    
    //S_c3
    $display("ps shold be S_c3");
    if(DUT.state_machine.ps != `S_c3) begin
        $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_c3);
            err = 1'b1;
    end
    #10;
        
    //ps should be in wait state_machine
    $display("ps should be in wait state_machine");
    if(DUT.state_machine.ps !=  4'b0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0000);
            err = 1'b1;
    end

    $display("checking value in Z");
    if(Z !=  1'b0)begin
            $display("ERROR ** output is %b, expected %b", Z, 1'b0);
            err = 1'b1;
    end
    $display("checking value in N");
    if(N !=  1'b1)begin
            $display("ERROR ** output is %b, expected %b", N, 1'b1);
            err = 1'b1;
    end
    $display("checking value in V");
    if(V !=  1'b0)begin
            $display("ERROR ** output is %b, expected %b", V, 1'b0);
            err = 1'b1;
    end


    

//     ////////////////////////////////////////////////////////////AND//////////////////////////////////////////////////////////////////////////////
//IN this section we operate logical operation , &. WE annded R0 and R3 and put result into R4
// Since R0 = 7 = 0111 and R3 = 12 = 1100 we should have R4 = 0000_0000_0000_0100
load = 1'b1; in =16'b1011_0011_1000_0000; reset = 1'b1; 
#10;
//checking if ps is in the wait state_machine
    $display("checking value in ps");
    if(w != 1'b1)begin
            $display("ERROR ** output is %b, expected %b", w , 1'b1);
            err = 1'b1;
    end

    s = 1'b1; reset = 1'b0;
    #10

    //ps should be in Decode state_machine
    $display("checking ps should be in Decode state_machine");
    if(DUT.state_machine.ps !=  4'b0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0001);
            err = 1'b1;
    end
    
    #10;
    //ps should be S_a1 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a1");
    if(DUT.state_machine.ps !=  `S_a1)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_a1);
            err = 1'b1;
    end

    #10;
    //ps should be S_a2 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a2");
    if(DUT.state_machine.ps !=  `S_a2)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_a2);
            err = 1'b1;
    end

    #10;
    //ps should be S_a3 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a3");
    if(DUT.state_machine.ps !=  `S_a3)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_a3);
            err = 1'b1;
    end
    
    #10;
    //ps should be S_a1 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a4");
    if(DUT.state_machine.ps !=  `S_a4)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_a4);
            err = 1'b1;
    end

    #10;
    //ps should be in wait state_machine
    $display("ps should be in wait state_machine");
    if(DUT.state_machine.ps !=  4'b0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0000);
            err = 1'b1;
    end
    $display("checking value in R4");
    if(DUT.DP.REGFILE.R4 !=  16'b0000_0000_0000_0100)begin
            $display("ERROR ** output is %b, expected %b", DUT.DP.REGFILE.R4 , 16'b0000_0000_0000_0100);
            err = 1'b1;
    end

//   ///////////////////////////////////////////  //MVN negating R0 -> R5////////////////////////////////////////////////////////////////////////////
//THis section tests MVn instruction. 
// WE negate number in R0 and put result in R5
//Since R0 = 7 = 0000_0000_0000_0111, we should see R5 = 1111_1111_1111_1000
load = 1'b1; in =16'b1011_1000_1010_0000; reset = 1'b1; 
#10;
//checking if ps is in the wait state_machine
    $display("checking value in ps");
    if(w != 1'b1)begin
            $display("ERROR ** output is %b, expected %b", w , 1'b1);
            err = 1'b1;
    end

    s = 1'b1; reset = 1'b0;
    #10

    //ps should be in Decode state_machine
    $display("checking ps should be in Decode state_machine");
    if(DUT.state_machine.ps !=  4'b0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0001);
            err = 1'b1;
    end
    
    #10;
    //ps should be S_a1 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_mvn1");
    if(DUT.state_machine.ps !=  `S_mvn1)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_mvn1);
            err = 1'b1;
    end

    #10;
    // ps should be in s_mvn2
    $display("ps should be s_mvn2");
    if(DUT.state_machine.ps !=  `S_mvn2)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_mvn2);
            err = 1'b1;
    end

    #10;
    //ps should be S_a3 state_machine which writes num in specified register in regfile(memory)
    $display("ps should be s_a3");
    if(DUT.state_machine.ps !=  `S_mvn3)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , `S_mvn3);
            err = 1'b1;
    end

    #10;
    //ps should be in wait state_machine
    $display("ps should be in wait state_machine");
    if(DUT.state_machine.ps !=  4'b0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.state_machine.ps , 4'b0000);
            err = 1'b1;
    end
    $display("checking value in R4");
    if(DUT.DP.REGFILE.R5 !=  16'b1111_1111_1111_1000)begin
            $display("ERROR ** output is %b, expected %b", DUT.DP.REGFILE.R5 , 16'b1111_1111_1111_1000);
            err = 1'b1;
    end
    

    // end of testbench   
    //display PASSED if no error, else display FAILED 
    if(~err) $display("PASSED");
    else $display ("FAILED");
    #10;
    $stop;
end

endmodule

/**
Put last 8 digits with SW-9 being 0
then when SW-9 is 1 put upper 8 bits

16'b1101_0000_0000_0111 MOV R0, #7
16'b1101_0001_0000_0101 MOV R1, #5
16'b1010_0000_0110_0001 ADD R3, R0, R1 -> 12




16'b1101_0000_0000_0111 MOV R0, #7
Press clk (KEY0) and load (KEY3) at same time
Then clk (KEY0) and reset (KEY1)
Then clk (KEY0) and s (KEY2)
Then clk twice

16'b1101_0001_0000_0101 MOV R1, #5
Press clk (KEY0) and load (KEY3) at same time
Then clk (KEY0) and reset (KEY1)
Then clk (KEY0) and s (KEY2)
Then clk twice

16'b1010_0000_0110_0001 ADD R3, R0, R1 -> 12
Press clk (KEY0) and load (KEY3) at same time
Then clk (KEY0) and reset (KEY1)
Then clk (KEY0) and s (KEY2)
Then clk 5 times

**/