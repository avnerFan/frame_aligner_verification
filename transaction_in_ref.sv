class transaction_in_ref;
  
  // Input signals observed by reference model
  bit reset;
  bit [7:0] data_in; // Input byte to DUT / ref model
  
  // Debug print
  function void display(string name);
    $display("");
    $display("---------- %s ----------", name);
    $display("data_in = %h, reset = %b, Time = %0t",data_in, reset, $time);
    $display("------------------------");
  endfunction
  
endclass
