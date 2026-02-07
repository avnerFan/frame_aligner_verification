class driver;
  
  // Virtual interface to DUT
  virtual frame_aligner_if drv_dut_if;
  
  // Communication Channel
  mailbox gen2drv;
  
  // Event signaling reset completion
  event reset_done;
  
  // Constructor
  function new(mailbox gen2drv);
    this.gen2drv    = gen2drv;
    this.drv_dut_if = frame_aligner_pkg::global_if;
  endfunction // new
  
  int j;
  
  // Main driver task (waits for reset, then sends frames)
  task run();
    wait(reset_done.triggered); // Wait until reset completes
    forever begin
      transaction_in trans_in;
      gen2drv.get(trans_in); // Block until generator provides a new transaction
      trans_in.display("Driver");
      drv_dut_if.frame_start <= 1; // Assert frame_start to mark the start of a new frame, allowing monitor_in and Coverage to treat it as a single aligned frame

      @(posedge drv_dut_if.clock);
      drv_dut_if.rx_data = trans_in.header[7:0]; // Send HEADER LSB byte
      drv_dut_if.frame_start <= 0; // De-assert frame_start after first cycle
      //$display("driver - header lsb - %0h",drv_dut_if.rx_data);
      @(posedge drv_dut_if.clock);
      drv_dut_if.rx_data = trans_in.header[15:8]; // Send HEADER MSB byte
      //$display("driver - header msb - %0h",drv_dut_if.rx_data);
      j=0;
      for (int i = 0; i < 10; i++) begin // Send PAYLOAD bytes (80 bits = 10 bytes)
        @(posedge drv_dut_if.clock);
	    drv_dut_if.rx_data = trans_in.payload[i*8 +: 8];
        //$display("driver - data %0d - %0h",j,drv_dut_if.rx_data);
        j++;
      end
    end
  endtask // run
  
  // Reset task
  task perform_reset();
    @(negedge drv_dut_if.clock);
    $display("reset asserted at %0t", $time);
    drv_dut_if.reset = 1;
    @(negedge drv_dut_if.clock);
    drv_dut_if.reset = 0;
    $display("reset de-asserted at %0t", $time);
    -> reset_done; // Notify driver/run task that reset is done
  endtask : perform_reset
  
endclass
