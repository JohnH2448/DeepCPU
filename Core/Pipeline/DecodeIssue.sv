import Configuration::*;
import Payloads::*;
import Enumerations::*;




// ============ ISSUER MUST ============
// Deposit RD and PC to ROB
// On No WB, hardwire rd=x0

// ============ ISSUE RULES ============
// Slot 0 is always older
// Memory must flow through slot 0
// Memory Queue must have space for new memory ops
// No issues on dependencies on loads that are !ready
// ROB must have space for new instructions
// No slot 0 + slot 1 dependencies
// No dual redirect issues
// Block WAW to prevent forwarding complications
// Assess Memory Queue fullness as x-1 to accomindate in flight