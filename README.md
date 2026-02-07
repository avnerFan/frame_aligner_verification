Technical Specification — Frame Aligner Verification

This project verifies a SystemVerilog frame aligner DUT that performs real-time synchronization on a continuous 8-bit data stream by detecting predefined frame headers.


Each frame consists of:
* 16-bit header (valid patterns: 0xAFAA, 0xBA55)
* 80-bit payload
* Back-to-back transmission with no idle cycles between frames 


The DUT asserts in-frame alignment when three consecutive valid headers are detected and asserts out-of-frame when four consecutive invalid headers occur.
The module also outputs byte position tracking across header and payload fields (fr_byte_position[3:0]) and an alignment status signal (frame_detect) .


Verification Architecture
The verification environment is implemented in SystemVerilog and includes:
* A transaction-level frame_item class with constrained randomization for:
    * Header type (valid / illegal)
    * Payload length and content
* A driver that serializes frames onto the DUT input according to the RX protocol
* A monitor that reconstructs frames and forwards them to scoreboarding and coverage
* A scoreboard that validates header detection, alignment transitions, and payload integrity
* Functional coverage tracking header sequences, alignment states, error cases, and corner scenarios
* Directed and randomized tests, including valid bursts, illegal bursts, and mixed traffic patterns 

Verification Goals
* Validate correct frame boundary detection
* Ensure accurate alignment acquisition and loss behavior
* Confirm robustness under invalid header injection
* Achieve high functional coverage across header combinations and payload conditions
* Detect protocol violations and corner-case failures early in simulation
