package frame_aligner_pkg;

  // Total number of transactions per simulation run
  parameter TRANSACTION_COUNT =100;

  // virtual interface
  virtual frame_aligner_if global_if;

  //include classes
  `include "transaction_in.sv"
  `include "transaction_out.sv"
  `include "transaction_in_ref.sv"
  `include "fa_ref_model.sv"
  `include "scoreboard.sv"
  `include "coverage.sv"
  `include "monitor_in.sv"
  `include "monitor_out.sv"
  `include "driver.sv"
  `include "generator.sv"
  `include "environment.sv"
  `include "test.sv"

endpackage : frame_aligner_pkg
