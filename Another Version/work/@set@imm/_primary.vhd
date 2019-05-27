library verilog;
use verilog.vl_types.all;
entity SetImm is
    port(
        instr_type      : in     vl_logic_vector(6 downto 0);
        instr           : in     vl_logic_vector(31 downto 0);
        imm             : out    vl_logic_vector(31 downto 0)
    );
end SetImm;
