-------------------------------------------------------------------------------
-- File         : gp_custom_simple_arch.vhd
-- Description  : simple, I/O buffer architecture for gp_custom
-- Author       : Sabih Gerez, University of Twente
-- Creation date: September 6, 2015
-------------------------------------------------------------------------------
-- $Rev: 1$
-- $Author: gerezsh$
-- $Date: Thu Sep 29 11:57:46 CEST 2022$
-- $Log$
-------------------------------------------------------------------------------


architecture simple of gp_custom is

  type buf_memory is array (0 to 7) of std_logic_vector (31 downto 0);

  signal in_buf, out_buf: buf_memory;
  signal in_trigger, out_trigger: std_logic;

  signal in_busy, out_busy: std_logic;

begin
  -- INPUT MAPPING --
  -- add <= avs_addr(5 downto 2);

  -- bus interface
  bus_if:  process(resetn, clk)
    variable i: integer range 0 to 7;
  begin
    if resetn = '0'
    then
      for i in 0 to 7 loop
        out_buf(i) <= (others => '0');
      end loop;
      in_trigger <= '0';
      out_trigger <= '0';
      stop_sim <= '0';
      avs_readdata <= X"55555555"; -- alternating 0/1 pattern
    elsif rising_edge(clk)
    then
      if avs_write = '1' -- Nios is writing
      then
        case to_integer(unsigned(avs_addr)) is
          when 0 to 7 => -- write memory
            out_buf(to_integer(unsigned(avs_addr))) <= avs_writedata;
          when 8 => -- request new external data 
            in_trigger <= avs_writedata(0); -- only LSB matters!
          when 9 => -- request data flush to external
            out_trigger <= avs_writedata(0); -- only LSB matters!
          when 12 => -- request to stop simulation
            stop_sim <= '1'; -- ignore data value
          when others => null;
        end case;
      else
        -- clear triggers; they should be cleared within 16 clock
        -- cycles after setting them; it is pretty safe to use 
        -- the absence of "avs_write" for this purpose. 
        in_trigger  <= '0';
        out_trigger <= '0';
        if avs_read = '1'  -- Nios is reading
        then
          case to_integer(unsigned(avs_addr)) is
            when 0 to 7 => -- read memory
              avs_readdata <= in_buf(to_integer(unsigned(avs_addr)));
            when 8 => -- request new external data 
              avs_readdata <= (31 downto 1 => '0', 0 => in_trigger);
            when 9 => -- request data flush to external
              avs_readdata <= (31 downto 1 => '0', 0 => out_trigger);
            when 10 => -- input from external ready?
              avs_readdata <= (31 downto 1 => '0', 0 => in_busy);
            when 11 => -- output to external ready?
              avs_readdata <= (31 downto 1 => '0', 0 => out_busy);
            when others => 
              avs_readdata <= X"55555555"; -- alternating 0/1 pattern
          end case;
        end if; -- avs_read
      end if; -- avs_write
    end if; -- rising edge
  end process bus_if;

  -- input buffer
  inputs: process(resetn, clk)
    variable i: integer range 0 to 7;
    variable in_counter: integer range 0 to 7;
    variable odd: std_logic;
  begin
    if resetn = '0'
    then
      for i in 0 to 7 loop
        in_buf(i) <= (others => '0');
      end loop;
      in_busy <= '0';
      siso_req <= '0';
      in_counter := 0;
      odd := '0';
    elsif rising_edge(clk)
    then
      if in_busy = '1'
      then
        if odd = '0'
        then
          in_buf(in_counter)(15 downto 0) <= siso_data_in;
          odd := '1';
        else -- odd = '1'
          in_buf(in_counter)(31 downto 16) <= siso_data_in;
          odd := '0';
          if in_counter = 7
          then
            siso_req <= '0';
            in_busy <= '0';
          else
            in_counter := in_counter + 1;
          end if;
        end if;
      elsif in_trigger = '1'
      then
        in_busy <= '1';
        siso_req <= '1';
        in_counter := 0;
      end if;
    end if;
  end process inputs;

  -- output buffer
  outputs: process(resetn, clk)
    variable out_counter: integer range 0 to 7;
    variable odd: std_logic;
  begin
    if resetn = '0'
    then
      siso_data_out <= (others => '0');
      out_busy <= '0';
      siso_ready <= '0';
      out_counter := 0;
      odd := '0';
    elsif rising_edge(clk)
    then
      if out_busy = '1'
      then
        if odd = '0'
        then 
          siso_data_out <= out_buf(out_counter)(15 downto 0);
          odd := '1';
          siso_ready <= '1';
        else
          siso_data_out <= out_buf(out_counter)(31 downto 16);
          odd := '0';
          siso_ready <= '1';
          if out_counter = 7
          then
            out_busy <= '0';
          else
            out_counter := out_counter + 1;
          end if;
        end if;
      else
        siso_ready <= '0';
        if out_trigger = '1'
        then
          out_busy <= '1';
          out_counter := 0;
        end if;
      end if;
    end if;
  end process outputs;

  -- connect clock for SISO
  clk_out <= clk;

end architecture simple; -- of gp_custom
