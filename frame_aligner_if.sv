interface frame_aligner_if ();
  
  // internal signals
  logic reset;
  logic clock;
  logic [3:0] fr_byte_position;
  logic frame_detect;
  logic [7:0] rx_data;
  
  logic frame_start;
  
endinterface
