`timescale 1ns/1ps
module tb_mult36x36_advanced;
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
  // helper temporaries declared at module scope for Verilog-2001 compatibility
  reg [63:0] r;
  reg [63:0] r1;
  reg [63:0] r2;
  reg signed [35:0] A[0:7];
  reg signed [35:0] B[0:7];
  integer idx;

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

  // mode: 0=basic, 1=random, 2=boundary, 3=pipeline
  integer mode = 1;
  integer NV = 256; // number of vectors for random/pipeline
  integer seed = 0;

  // boundary constants for signed 36-bit
  localparam signed [35:0] MAX36 = 36'sd34359738367;
  localparam signed [35:0] MIN36 = -36'sd34359738368;

  initial begin
    // parse plusargs
    if (!$value$plusargs("mode=%d", mode)) mode = 1;
    if (!$value$plusargs("nv=%d", NV)) NV = 256;
    if (!$value$plusargs("seed=%d", seed)) seed = 0;

    if (seed == 0) seed = $random;
    $display("Running advanced mult36x36 TB: mode=%0d nv=%0d seed=%0d", mode, NV, seed);

    $dumpfile("wave.vcd");
    $dumpvars(0, tb_mult36x36_advanced);

    // reset
    rstn = 0; ce = 0; valid_in = 0; data_a = 0; data_b = 0;
    #20; // two clock cycles
    rstn = 1;
    #10;

    case (mode)
      0: begin // basic (short set)
        data_a = 36'sd0; data_b = 36'sd0; expected = data_a * data_b; ce = 1; valid_in = 1; @(posedge clk); #1; check_and_report(0);
        valid_in = 0; ce = 0; @(posedge clk);
        data_a = 36'sd1; data_b = 36'sd1; expected = data_a * data_b; ce = 1; valid_in = 1; @(posedge clk); #1; check_and_report(1);
      end

      1: begin // random vectors
        // Initialize RNG
        for (idx = 0; idx < NV; idx = idx + 1) begin
          r = {$random(seed), $random(seed)};
          data_a = r[35:0];
          r = {$random(seed), $random(seed)};
          data_b = r[35:0];

          expected = $signed(data_a) * $signed(data_b);
          ce = 1; valid_in = 1;
          @(posedge clk);
          #1;
          if (valid_out) begin
            if (mult_result !== expected) begin
              $display("ERROR: rand vec %0d: a=%0d b=%0d got=%0d exp=%0d", idx, data_a, data_b, mult_result, expected);
              errors = errors + 1;
            end
          end else begin
            $display("WARNING: rand vec %0d produced no valid_out", idx);
          end
          valid_in = 0; ce = 0;
        end
      end

      2: begin // boundary tests
        A[0] = MAX36; B[0] = MAX36;
        A[1] = MIN36; B[1] = MIN36;
        A[2] = MAX36; B[2] = 36'sd1;
        A[3] = MIN36; B[3] = 36'sd1;
        A[4] = MAX36; B[4] = -36'sd1;
        A[5] = -36'sd1; B[5] = MAX36;
        A[6] = 36'sd0; B[6] = MAX36;
        A[7] = -36'sd123456789; B[7] = 36'sd987654321;

        for (i = 0; i < 8; i = i + 1) begin
          data_a = A[i]; data_b = B[i]; expected = $signed(data_a) * $signed(data_b);
          ce = 1; valid_in = 1;
          @(posedge clk);
          #1;
          if (valid_out) begin
            if (mult_result !== expected) begin
              $display("ERROR: bound %0d: a=%0d b=%0d got=%0d exp=%0d", i, data_a, data_b, mult_result, expected);
              errors = errors + 1;
            end else begin
              $display("OK: bound %0d", i);
            end
          end
          valid_in = 0; ce = 0; @(posedge clk);
        end
      end

      3: begin // pipeline / back-to-back valid
        for (i = 0; i < NV; i = i + 1) begin
          r1 = {$random(seed), $random(seed)};
          r2 = {$random(seed), $random(seed)};
          data_a = r1[35:0]; data_b = r2[35:0];
          expected = $signed(data_a) * $signed(data_b);
          ce = 1; valid_in = 1; // keep valid high every cycle
          @(posedge clk);
          #1;
          if (valid_out) begin
            if (mult_result !== expected) begin
              $display("ERROR: pipe vec %0d: a=%0d b=%0d got=%0d exp=%0d", i, data_a, data_b, mult_result, expected);
              errors = errors + 1;
            end
          end else begin
            $display("WARNING: pipe vec %0d had no valid_out", i);
          end
        end
        // finish by deasserting valid
        valid_in = 0; ce = 0; @(posedge clk);
      end

      default: begin
        $display("Unknown mode %0d", mode);
      end
    endcase

    if (errors == 0) begin
      $display("ADVANCED MULT TEST PASSED");
      $finish;
    end else begin
      $display("ADVANCED MULT TEST FAILED: %0d errors", errors);
      $fatal;
    end
  end

  task check_and_report(input integer idx);
    begin
      #1;
      if (mult_result !== expected) begin
        $display("ERROR: vec %0d: a=%0d b=%0d got=%0d expected=%0d", idx, data_a, data_b, mult_result, expected);
        errors = errors + 1;
      end else begin
        $display("OK: vec %0d: a=%0d b=%0d result=%0d", idx, data_a, data_b, mult_result);
      end
    end
  endtask

endmodule
