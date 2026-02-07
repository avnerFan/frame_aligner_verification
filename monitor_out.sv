class monitor_out;
  
  // Virtual interface to DUT
  virtual frame_aligner_if mon_out_if;
  
  // Communication Channel
  mailbox mon_out2scrbrd;
  
  // Constructor
  function new(mailbox mon_out2scrbrd);
    this.mon_out2scrbrd = mon_out2scrbrd;
    this.mon_out_if = frame_aligner_pkg::global_if;
  endfunction // new
  
  // Main monitor loop
  task run();
    forever begin
      transaction_out trans_out = new();
      @(posedge mon_out_if.clock);
      #1;
      trans_out.fr_byte_position  = mon_out_if.fr_byte_position;
      trans_out.frame_detect = mon_out_if.frame_detect;
      mon_out2scrbrd.put(trans_out);
    end
  endtask // run
  
endclass
