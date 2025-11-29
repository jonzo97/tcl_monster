// uart_tx_voter.v - Single-bit majority voter for UART TX signals
//
// Implements fault-tolerant UART TX output using majority voting.
// Takes 3 TX signals from redundant UART instances and outputs
// the majority vote (2-of-3).
//
// Voting Logic:
//   - If 2 or more inputs are '1', output is '1'
//   - If 2 or more inputs are '0', output is '0'
//   - Single-bit faults are masked by majority
//
// Target: PolarFire FPGA
// TMR System: MI-V triple modular redundancy design

module uart_tx_voter (
    input  tx_a,      // TX output from UART instance A
    input  tx_b,      // TX output from UART instance B
    input  tx_c,      // TX output from UART instance C
    output tx_voted   // Voted TX output (majority of 3)
);

// Majority voting logic: (A & B) | (B & C) | (A & C)
// This implements 2-of-3 voting
assign tx_voted = (tx_a & tx_b) | (tx_b & tx_c) | (tx_a & tx_c);

endmodule
