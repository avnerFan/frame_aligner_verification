class generator;
  
  // Event: Signals when stimulus generation is complete
  event gen_finished;
  
  // State Tracking Counters
  int illegal_cnt = 0;  // Number of illegal headers sent in current phase
  int   legal_cnt = 0;  // Number of legal headers sent in current phase
  
  // Generator State Machine - controls what type of transaction to send
  typedef enum {
    SEND_ILLEGAL, // Send illegal header frames
    SEND_LEGAL,   // Send legal header frames
    SEND_RANDOM   // Send fully randomized traffic
  } gen_state_t;
  
  gen_state_t state = SEND_LEGAL; // Start with legal traffic phase
  
  // Current Transaction Object
  transaction_in trn_in;
  
  // Communication Channel to Driver
  mailbox gen2drv;
  
  // Constructor
  function new(mailbox gen2drv);
    this.gen2drv = gen2drv; 
  endfunction
  
  // Main Stimulus Generation Task
  task run();
    repeat (TRANSACTION_COUNT) begin
      trn_in = new();
      case (state)
        
        // Phase 1: Send 3 Legal Header Transactions
        SEND_LEGAL: begin
          if (!trn_in.randomize() with {header_type inside {HEADER_1, HEADER_2};}) $fatal("generator:: Legal randomization failed");
          legal_cnt++;
          if (legal_cnt == 3) begin
            state = SEND_ILLEGAL;
          end
        end

        // Phase 2: Send 4 Illegal Header Transactions
        SEND_ILLEGAL: begin
          if (!trn_in.randomize() with {header_type == ILLEGAL;}) $fatal("generator:: Illegal randomization failed");
          illegal_cnt++;
          if (illegal_cnt == 4) begin
            state = SEND_RANDOM;
          end
        end

        // Phase 3: Random Traffic
        SEND_RANDOM: begin
          if (!trn_in.randomize()) $fatal("generator:: Random randomization failed");
        end

      endcase
      
      // Send transaction to driver
      gen2drv.put(trn_in);
      
    end // repeat
    
    // Signal that stimulus generation is complete
    -> gen_finished;
   
  endtask
  
endclass
