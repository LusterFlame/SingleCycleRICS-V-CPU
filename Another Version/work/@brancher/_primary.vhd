library verilog;
use verilog.vl_types.all;
entity Brancher is
    port(
        clk             : in     vl_logic;
        mode            : in     vl_logic_vector(2 downto 0);
        rs1             : in     vl_logic_vector(31 downto 0);
        rs2             : in     vl_logic_vector(31 downto 0);
        target1         : in     vl_logic_vector(31 downto 0);
        target2         : in     vl_logic_vector(31 downto 0);
        target_result   : out    vl_logic_vector(31 downto 0)
    );
end Brancher;
