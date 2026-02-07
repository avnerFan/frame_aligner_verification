class environment;
  
  // Core verification components
  generator   gen;        // Produces stimulus transactions
  driver      drv;        // Drives transactions into DUT
  monitor_in  mon_in;     // Observes DUT input traffic
  monitor_out mon_out;    // Observes DUT output traffic
  scoreboard  scrbrd;     // Compares DUT vs reference model
  coverage    cov;        // Collects functional coverage
  
  // Communication Channels (Mailboxes)
  mailbox gen2drv;          // Generator  -> Driver
  mailbox mon_in2scrbrd;    // Input Monitor -> Scoreboard
  mailbox mon_out2scrbrd;   // Output Monitor -> Scoreboard
  mailbox mon_in2cov;       // Input Monitor -> Coverage
  
  // Constructor
  function new(event error_event);
    // Mailboxes
    gen2drv        = new(1);
    mon_in2scrbrd  = new(1);
    mon_out2scrbrd = new(1);
    mon_in2cov     = new(1);
    // Instantiate verification components
    gen     = new(gen2drv);
    drv     = new(gen2drv);
    mon_in  = new(mon_in2scrbrd, mon_in2cov);
    mon_out = new(mon_out2scrbrd);
    scrbrd  = new(mon_in2scrbrd, mon_out2scrbrd, error_event);
    cov     = new(mon_in2cov);
  endfunction
  
  // Top-Level Test Execution Flow
  task run_test();
    pre_run();     // Setup / initialization
    main_run();    // Run parallel test components
    post_run();    // Cleanup / reporting
  endtask
  
  task pre_run;
    // Placeholder: add config, seed logs, warmup, etc.
  endtask
  
  // Main Execution Phase - runs all active verification components concurrently
  task main_run();
    fork
      mon_in.run();
      mon_out.run();
      gen.run();
      drv.run();
      scrbrd.run();
      cov.run();
      drv.perform_reset();
    join_none
    @gen.gen_finished;
    #20;
    
  endtask
  
  task post_run();
    // Placeholder: final reports, coverage dump, etc.
  endtask
  
endclass
