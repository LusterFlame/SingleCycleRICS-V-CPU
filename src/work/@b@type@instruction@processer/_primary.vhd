library verilog;
use verilog.vl_types.all;
entity BTypeInstructionProcesser is
    port(
        PC              : in     vl_logic_vector(31 downto 0);
        imm             : in     vl_logic_vector(12 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        REG_1           : in     vl_logic_vector(31 downto 0);
        REG_2           : in     vl_logic_vector(31 downto 0);
        NewPC           : out    vl_logic_vector(31 downto 0)
    );
end BTypeInstructionProcesser;
