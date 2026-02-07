class test;
  
  // Environment Instance
  environment env;
  
   // Constructor - receives shared error event from testbench top
  function new(event error_event);
    this.env = new(error_event);
  endfunction
  
  // Run test
  task run_test ();
    env.run_test();
  endtask
  
endclass
