class scoreboard;
  
  // Communication channels
  mailbox mon_in2scrbrd;
  mailbox mon_out2scrbrd;
  
  // Reference model & events
  fa_ref_model ref_mod;
  event error_event;
  event scrbrd_done;
  
  // Constructor
  function new(mailbox mon_in2scrbrd, mailbox mon_out2scrbrd, event error_event);
    this.mon_in2scrbrd  = mon_in2scrbrd;
    this.mon_out2scrbrd = mon_out2scrbrd;
    
    this.error_event    = error_event;
    
    ref_mod             = new();
  endfunction
  
  // Main scoreboard loop
  task run();  
    forever begin
      // Incoming observed transactions
      transaction_in_ref trns_in_ref = new();
      transaction_out trns_out = new();
      // Expected transaction from reference model
      transaction_out trns_ref;
      
      // Get monitored transactions
      mon_in2scrbrd.get(trns_in_ref);
      mon_out2scrbrd.get(trns_out);
      
      // Generate expected output
      trns_ref = ref_mod.gen_ref_transaction(trns_in_ref);
      
      // Compare expected vs actual
      if (!trns_ref.compare(trns_out)) begin
        $display("At time %0t - ERROR reported by scoreboard", $time);
        trns_in_ref.display("Monitor In");
        trns_out.display("Monitor Out");
        trns_ref.display("Reference Model");
        -> error_event;
      end
    end // forever
  endtask
  
endclass
