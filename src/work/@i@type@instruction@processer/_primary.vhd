library verilog;
use verilog.vl_types.all;
entity ITypeInstructionProcesser is
    port(
        funct3          : in     vl_logic_vector(2 downto 0);
        imm             : in     vl_logic_vector(11 downto 0);
        REG             : in     vl_logic_vector(31 downto 0);
        REG_F           : out    vl_logic_vector(31 downto 0)
    );
end ITypeInstructionProcesser;
