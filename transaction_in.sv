class transaction_in;
  
  // Header type encoding
  typedef enum bit [1:0] {
    ILLEGAL,
    HEADER_1,
    HEADER_2
  } header_t;
  
  // Randomized transaction fields
  rand header_t   header_type; // Header category selector
  rand bit [15:0] header;      // Actual header word
  rand bit [79:0] payload;     // Frame payload
  
  // Distribution constraint for header type (currently equal probability)
  constraint header_dist_c {
    header_type dist {ILLEGAL, HEADER_1, HEADER_2};
  }
  
  // Header value constraint
  constraint header_c { 
    // Valid header patterns
    (header_type == HEADER_1) -> header == 16'hAFAA;
    (header_type == HEADER_2) -> header == 16'hBA55;
    // Illegal header must NOT match legal ones
    (header_type == ILLEGAL) -> !(header inside {16'hAFAA, 16'hBA55});
  }
  
  // Debug print
  function void display(string name);
    $display("");
    $display("---------- %s ----------", name);
    $display("HeaderType = %0d Header = %h, Payload = %h, Time = %0t",header_type, header, payload, $time);
    $display("------------------------");
  endfunction
  
endclass
