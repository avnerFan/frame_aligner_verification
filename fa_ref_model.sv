class fa_ref_model;
  
  // FSM States for Frame Detection
  typedef enum logic [1:0] {
    IDLE,      // Waiting for possible frame header LSB
    FR_HLSB,   // Got LSB candidate, expecting MSB
    FR_HMSB,   // Header complete, move to payload
    FR_DATA    // Inside payload bytes
  } state_t;
  
  state_t   state = IDLE;
  
  // Frame Detection Tracking
  bit [1:0] legal_frame_counter; // Count consecutive legal frames
  bit [5:0] na_frame_counter;    // Non aligned bytes count
  
  
  bit       header_lsb_type_1;  // Saw AA (lsb of 16'hAFAA)
  bit       header_lsb_type_2;  // Saw 55 (lsb of 16'hBA55)
  
  bit [3:0] fr_byte_position;   // Byte index inside frame (0–11)
  bit       frame_detect;       // Asserted after 3 aligned frames and deasserted after 48 unaligned bytes
  
  // Reference Model FSM Step
  function transaction_out gen_ref_transaction(transaction_in_ref trns_in_ref);
    
    transaction_out trns_ref = new();
    
    // RESET HANDLING
    if (trns_in_ref.reset) begin
      fr_byte_position = 4'h0;
      frame_detect = 0;
      state = IDLE;
      legal_frame_counter = 0;
      na_frame_counter = 0;
      header_lsb_type_1 = 0;
      header_lsb_type_2 = 0;
      trns_ref.frame_detect = frame_detect;
      trns_ref.fr_byte_position = fr_byte_position;
      return trns_ref;
    end // reset
    
    // Output assignment (from previous cycle state)
    trns_ref.fr_byte_position = fr_byte_position;
    trns_ref.frame_detect = frame_detect;
    
    // FSM State Transitions
    case (state)
      
      IDLE: begin
        header_lsb_type_1 = 0;
        header_lsb_type_2 = 0;
        fr_byte_position = 4'h0;
        header_lsb_type_1 = (trns_in_ref.data_in == 8'hAA);
        header_lsb_type_2 = (trns_in_ref.data_in == 8'h55);
        if (trns_in_ref.data_in == 8'hAA || trns_in_ref.data_in == 8'h55) state = FR_HLSB;
        else begin
          na_frame_counter++;
          legal_frame_counter = 0;       
        end
        // Lose lock if too many invalid bytes
        if (na_frame_counter >= 48) frame_detect = 0;
      end // IDLE
      
      FR_HLSB: begin
         fr_byte_position++;
        if ((trns_in_ref.data_in == 8'hAF && header_lsb_type_1) || (trns_in_ref.data_in == 8'hBA && header_lsb_type_2)) begin
          state = FR_HMSB;
          na_frame_counter = 0;
          legal_frame_counter++;   
        end
        else begin
          legal_frame_counter = 0;
          na_frame_counter   += 2;
          state               = IDLE;
        end
      end // FR_HLSB
      
      FR_HMSB: begin
        fr_byte_position++;
        // Lock frame detect after 3 consecutive valid headers
        if (legal_frame_counter >= 3) frame_detect = 1;
        state = FR_DATA;
      end // FR_HMSB
      
      FR_DATA: begin
        fr_byte_position++;
        // End of 12-byte frame → return to IDLE
        if (fr_byte_position == 11) state = IDLE;
      end // FR_DATA
      
    endcase
    return trns_ref;
    
  endfunction
  
endclass
