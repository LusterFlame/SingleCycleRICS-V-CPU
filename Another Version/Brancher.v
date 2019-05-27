module Brancher(
	input			clk,
	input [ 2:0]	mode,
	input [31:0]	rs1,
	input [31:0]	rs2,
	input [31:0]	target1,
	input [31:0]	target2,
	output reg [31:0] target_result
);

always @(posedge clk)
begin
	case(mode)
		3'b000: target_result = (rs1 == rs2 ? target1 : target2);
		3'b001: target_result = (rs1 != rs2 ? target1 : target2);
		3'b100: target_result = ($signed(rs1) < $signed(rs2) ? target1 : target2);
		3'b101: target_result = ($signed(rs1) >= $signed(rs2) ? target1 : target2);
		3'b110: target_result = (rs1 < rs2 ? target1 : target2);
		3'b111: target_result = (rs1 >= rs2 ? target1 : target2);
		default: begin end
	endcase
	$display("    rs1 = %b",rs1);
	$display("    rs2 = %b",rs2);
	$display("target1 = %b",target1);
	$display("target2 = %b",target2);
	$display("I chose = %b",target_result);
end

endmodule // Brancher