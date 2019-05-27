module Adder(
	input [31:0] IN1,
	input [31:0] IN2,
	output[31:0] RESULT
);

assign RESULT = $signed(IN1) + $signed(IN2);
// always @ (IN1 or IN2)
// begin
// 	RESULT = $signed(IN1) + $signed(IN2);
// end

endmodule // Adder