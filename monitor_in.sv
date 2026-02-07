class monitor_in;

  // Virtual interface to DUT
  virtual frame_aligner_if mon_in_if;
  
  // Communication Channels (Mailboxes)
  mailbox mon_in2cov;
  mailbox mon_in2scrbrd;
  
  bit dirty_trans = 0; // dirty_trans = 1 means current packet is invalid (e.g., reset occurred mid-frame)
  bit [95:0] frame;    // Assembled 96-bit frame (12 bytes)
  bit [7:0] din_q[$];  // Byte queue for collecting incoming frame data
  
  // Constructor
  function new(mailbox mon_in2scrbrd, mailbox mon_in2cov);
    this.mon_in2scrbrd = mon_in2scrbrd;
    this.mon_in2cov    = mon_in2cov;
    this.mon_in_if     = frame_aligner_pkg::global_if; // Bind global virtual interface
  endfunction // new
  
  // Main monitor loop - samples input data and assembles aligned frames
  task run();
    forever begin
      transaction_in_ref trans_in_ref = new();
      
      @(posedge mon_in_if.clock);
      #0;
      trans_in_ref.reset  = mon_in_if.reset;
      trans_in_ref.data_in = mon_in_if.rx_data;
      mon_in2scrbrd.put(trans_in_ref); // Send raw transaction to scoreboard
      
      if (mon_in_if.reset) dirty_trans = 1; // Reset handling: mark current packet as invalid
      if (mon_in_if.frame_start) begin // Frame boundary detected -> start fresh packet
        din_q.delete();
        dirty_trans = 0;
      end
      din_q.push_back(mon_in_if.rx_data); // Push incoming byte into queue
      if (din_q.size() == 12) begin // If we collected 12 bytes -> assemble 96-bit frame
        if (!dirty_trans) begin // Only send frame if no reset corrupted it
          frame = '0;

          foreach (din_q[i]) begin // Pack bytes MSB-first into 96-bit frame
            frame[95 - (i*8) -: 8] = din_q[i];
          end

          mon_in2cov.put(frame);
        end

      end
             
    end
  endtask // run
  
endclass
