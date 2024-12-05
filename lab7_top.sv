module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

  wire clk = ~KEY[0];
  wire reset = ~KEY[1];

  wire[15:0]din, dout, write_data, read_data;
  wire[8:0] mem_addr;
  wire[1:0] mem_cmd;
  wire [7:0] rd15, rd7;

  wire write, is_mwrite, is_read, msel, enable, slider, led;
  wire [7:0] LEDS, write_address, read_address;
  wire N, V, Z;

  //MWRITE and WREAD 
  `define MWRITE 2'b00
  `define MREAD 2'b01
  `define MNONE 2'b10
  

  cpu CPU(clk, reset, read_data, write_data, mem_addr, mem_cmd, N, V, Z);

  assign din = write_data;

  RAM MEM(clk, read_address, write_address, write, din, dout);

  //tristate #7 in figure 4
  assign read_data = enable ? dout: {16{1'bz}};

  //equality #8
  
  assign write_address = mem_addr[7:0];
  assign read_address = mem_addr[7:0];

  equal #2 IS_Write(`MWRITE, mem_cmd, is_mwrite);
  equal #2 IS_Read(`MREAD, mem_cmd, is_read);
  equal is_msel(1'b0, mem_addr[8], msel);

  assign write = msel & is_mwrite;
  assign enable = msel & is_read;

  assign read_data = enable ? dout : {16{1'bz}};
  
  //figure 7 sliders
  slider sliders(mem_cmd, mem_addr, slider);
  assign rd15 = slider ? 8'h00 : {8{1'bz}};
  assign rd7 = sliders ? SW[7:0] : {8{1'bz}};
  assign read_data = {rd15, rd7};

  //figure 7 leds
  leds leds(mem_cmd, mem_addr, led);
  vDFF1 #8 flipflop(clk, write_data[7:0], led, LEDS);
  assign LEDR = LEDS;

  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

endmodule

//sliders
module slider(mem_cmd, mem_addr, out);
  input [1:0] mem_cmd;
  input [8:0] mem_addr;
  output out;
  reg out;

  always @(*)begin
  if(mem_addr == `MREAD & mem_addr == 9'h140)
    out = 1'b1;
  else
    out = 1'b0;
  end

endmodule

//leds
module leds(mem_cmd, mem_addr, out);
  input [1:0] mem_cmd;
  input [8:0] mem_addr;
  output out;
  reg out;
  
  always @(*) begin
    if(mem_addr == `MWRITE & mem_addr == 9'h100)
    out = 1'b1;
  else
    out = 1'b0;

  end
  

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

module equal(a, b, c);
  parameter n = 1'b1;
  input[n-1:0] a, b;
  output c;
  reg c;

  always @(*)begin 
    if(a==b)
      c = 1'b1;
    else
      c = 1'b0;
  end

endmodule


module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 16; 
  parameter addr_width = 8;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule

