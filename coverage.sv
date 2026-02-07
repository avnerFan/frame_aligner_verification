class coverage;
  
  // Communication Channel (receiving aligned frames from monitor_in)
  mailbox mon_in2cov;
  
  bit [95:0] frame_in;  // Frame storage (96-bit = 12 bytes)
  bit [15:0] data_word; // Temporary 16-bit word used when scanning payload
  
  // shift register for last 4 headers
  logic [3:0] valid_header_sr = 4'bzzzz;
  
  bit [1:0] hdr_in_data = 2'b00; // Flags indicating whether known header patterns appear in payload
  
   // Coverage group definition
  covergroup fa_cov;
    // Track patterns of valid/invalid headers over last 4 frames
    four_invalid_and_three_valid_cp: coverpoint {valid_header_sr[3], valid_header_sr[2], valid_header_sr[1], valid_header_sr[0]} {
      bins four_invalid   = {4'b0000};
      bins three_valid = {4'b1110, 4'b1101, 4'b1011, 4'b0111};
    }
    
    // Detect partial header match in frame header bytes
    half_valid_header_cp: coverpoint {frame_in[95:88],frame_in[87:80]} {
      bins half_valid_header = {
        {8'hAF, 8'h55},
        {8'hBA, 8'hAA}
      };
    }
    
    // Detect header-like patterns appearing inside payload
    header_inside_payload_cp: coverpoint hdr_in_data {
      bins header1_in_data = {2'b01, 2'b11};
      bins header2_in_data = {2'b10, 2'b11};
    }
    
  endgroup
  
  // Constructor
  function new(mailbox mon_in2cov);
    this.mon_in2cov = mon_in2cov;
    this.fa_cov = new();
  endfunction //new
  
  // Main coverage sampling loop
  task run();
    forever begin
      mon_in2cov.get(frame_in); // Wait for aligned frame from monitor_in
      
      // Shift header-valid history (oldest shifts out)
      valid_header_sr[3] = valid_header_sr[2];
      valid_header_sr[2] = valid_header_sr[1];
      valid_header_sr[1] = valid_header_sr[0];
      valid_header_sr[0] = (frame_in [95:80] == 16'hAAAF || frame_in [95:80] == 16'h55BA);
      
      // scan payload for header values
      for (int i = 0; i < 80; i += 16) begin
        data_word = frame_in[i +: 16];
        if (data_word == 16'hAFAA) hdr_in_data[0] = 1'b1;
        if (data_word == 16'hBA55) hdr_in_data[1] = 1'b1;
      end
      
      fa_cov.sample();

    end
  endtask // run
  
endclass
