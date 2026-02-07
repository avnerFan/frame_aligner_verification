// frame aligner test bench top

`include "frame_aligner_if.sv"
`include "frame_aligner_pkg.sv"

module frame_aligner_tb_top ();
  
  // Import package (classes, params, virtual IF)
  import frame_aligner_pkg::*;
  
  // Clock & Reset
  logic clock;
  logic reset;
  
  // Global test status flag
  bit test_failed = 0;
  
  // Error event (triggered by scoreboard)
  event error_event;
  
  // Interface  instantiation
  frame_aligner_if tb_dut_if ();

  // Drive interface signals from TB
  assign tb_dut_if.clock = clock;
  assign tb_dut_if.reset = reset;
  
  // DUT instantiation
  frame_aligner dut (
    .clk              (tb_dut_if.clock),
    .rx_data          (tb_dut_if.rx_data),
    .reset            (tb_dut_if.reset),
    .fr_byte_position (tb_dut_if.fr_byte_position),
    .frame_detect     (tb_dut_if.frame_detect)
  );
  
  // Test class instance
  test tst;
    
  // Main test flow
  initial begin
    // Connect global virtual interface
    frame_aligner_pkg::global_if = tb_dut_if;
     // Create test instance and pass error event
    tst = new(error_event);
    // Run test
    tst.run_test();
    // Final result report
    if (test_failed) $display("===== TEST FAILED =====");
    else $display("===== TEST PASSED =====");
    // End simulation
    #1;
    $finish;
  end
  
  // Error monitor - listens for scoreboard error event
  initial begin
    forever begin
      @error_event;
      test_failed = 1;
    end
  end
    
  // clock generator
  initial begin         
    clock = 1;
    #5 forever #5 clock = ~clock;
  end
    
  // waveform dump
  initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
  end
endmodule
