class transaction_out;
  
  // DUT output fields
  bit [3:0] fr_byte_position;
  bit frame_detect;
  
  // Compare this transaction vs another (returns 1 = match, 0 = mismatch)
  function bit compare(transaction_out trns);
    if (fr_byte_position != trns.fr_byte_position) return 0;
    if (frame_detect != trns.frame_detect) return 0;
    return 1;
  endfunction
  
  // Debug print
  function void display(string name);
    $display("");
    $display("---------- %s ----------", name);
    $display("Byte Position = %0d, Frame Detect = %0b, Time = %0t",fr_byte_position, frame_detect, $time);
    $display("------------------------");
  endfunction
  
endclass
