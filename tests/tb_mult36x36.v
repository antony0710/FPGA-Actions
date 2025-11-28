`timescale 1ns/1ps
module tb_mult36x36;
  reg clk = 0;
  always #5 clk = ~clk; // 10ns period

  reg rstn;
  reg ce;
  reg valid_in;
  reg signed [35:0] data_a;
  reg signed [35:0] data_b;
  wire valid_out;
  wire signed [71:0] mult_result;

  integer i;
  integer errors = 0;
  reg signed [71:0] expected;

  // Instantiate DUT
  mult36x36 uut (
    .clk(clk),
    .rstn(rstn),
    .ce(ce),
    .valid_in(valid_in),
    .data_a(data_a),
    .data_b(data_b),
    .valid_out(valid_out),
    .mult_result(mult_result)
  );

  // Test vectors
  localparam NV = 8;
  reg signed [35:0] a_vec [0:NV-1];
  reg signed [35:0] b_vec [0:NV-1];

  initial begin
    // define vectors (36-bit signed literals)
    a_vec[0] = 36'sd0;                  b_vec[0] = 36'sd0;
    a_vec[1] = 36'sd1;                  b_vec[1] = 36'sd1;
    a_vec[2] = -36'sd1;                 b_vec[2] = 36'sd1;
    a_vec[3] = 36'sd123456;             b_vec[3] = -36'sd789;
    a_vec[4] = 36'sd34359738367;        b_vec[4] = 36'sd1; // max positive * 1
    a_vec[5] = -36'sd34359738368;       b_vec[5] = 36'sd1; // min negative * 1
    a_vec[6] = 36'sd123456789;          b_vec[6] = 36'sd98765;
    a_vec[7] = -36'sd123456789;         b_vec[7] = -36'sd98765;

    $dumpfile("wave.vcd");
    $dumpvars(0, tb_mult36x36);

    // reset
    rstn = 0; ce = 0; valid_in = 0; data_a = 0; data_b = 0;
    #20; // two clock cycles
    rstn = 1;
    #10;

    // apply vectors
    for (i = 0; i < NV; i = i + 1) begin
      data_a = a_vec[i];
      data_b = b_vec[i];
      ce = 1;
      valid_in = 1;
      @(posedge clk);
      #1; // let registers settle

      expected = $signed(data_a) * $signed(data_b);
      if (mult_result !== expected) begin
        $display("ERROR: vec %0d: a=%0d b=%0d got=%0d expected=%0d time=%0t", i, data_a, data_b, mult_result, expected, $time);
        errors = errors + 1;
      end else begin
        $display("OK: vec %0d: a=%0d b=%0d result=%0d", i, data_a, data_b, mult_result);
      end

      // deassert valid for one cycle to separate vectors
      valid_in = 0;
      ce = 0;
      @(posedge clk);
    end

    if (errors == 0) begin
      $display("MULT TEST PASSED");
      $finish;
    end else begin
      $display("MULT TEST FAILED: %0d errors", errors);
      $fatal;
    end
  end
endmodule
