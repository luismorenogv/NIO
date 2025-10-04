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


architecture mac of gp_custom is

  type buf_memory is array (0 to 7) of std_logic_vector (31 downto 0);

  signal in_buf, out_buf: buf_memory;
  signal in_trigger, out_trigger: std_logic;

  signal in_busy, out_busy: std_logic;

  -- coefficients, input/output sample, control/status, and state
  signal b0,b1,b2,a1,a2      : signed(15 downto 0) := (others=>'0');
  signal x_in                 : signed(15 downto 0) := (others=>'0');
  signal y_out_reg            : signed(15 downto 0) := (others=>'0');

  signal ctrl_start, ctrl_clr : std_logic := '0';
  signal status_done          : std_logic := '0';
  signal status_busy          : std_logic := '0';

  -- internal IIR state kept wide to avoid overflow
  signal z1, z2               : signed(31 downto 0) := (others=>'0');

  -- multiplier operands and results
  signal mul_a, mul_b         : signed(15 downto 0) := (others=>'0');
  signal mul_p                : signed(31 downto 0) := (others=>'0');  -- 16x16
  signal mul_q28              : signed(31 downto 0) := (others=>'0');  -- (a*b)>>8 (arith)

  -- FSM
    type mac_state_t is (
    IDLE,
    S1_SET, S1_USE,   -- m1 = b0 * x ; y   = z2 + m1
    S2_SET, S2_USE,   -- m2 = b1 * x ; tz2 = z1 + m2
    S3_SET, S3_USE,   -- m3 = a1 * y ; tz2 = tz2 + m3
    S4_SET, S4_USE,   -- m4 = b2 * x ; tz1 = m4
    S5_SET, S5_USE,   -- m5 = a2 * y ; tz1 = tz1 + m5
    FIN
  );
  signal mac_s : mac_state_t := IDLE;

  -- scratch regs used in the sequence
  signal y_acc                : signed(31 downto 0) := (others=>'0');
  signal t_z2, t_z1           : signed(31 downto 0) := (others=>'0');

  -- status "done" sticky bit
  signal status_done_sticky : std_logic := '0';

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
          when 16 => b0 <= signed(avs_writedata(15 downto 0));
          when 17 => b1 <= signed(avs_writedata(15 downto 0));
          when 18 => b2 <= signed(avs_writedata(15 downto 0));
          when 19 => a1 <= signed(avs_writedata(15 downto 0));
          when 20 => a2 <= signed(avs_writedata(15 downto 0));
          when 21 => x_in <= signed(avs_writedata(15 downto 0));
          when 23 =>  -- CTRL
            ctrl_start <= avs_writedata(0);
            ctrl_clr   <= avs_writedata(1);
            if avs_writedata(2)='1' then
              status_done_sticky <= '0';
            end if;
          when others => null;
        end case;
      else
        -- clear triggers; they should be cleared within 16 clock
        -- cycles after setting them; it is pretty safe to use 
        -- the absence of "avs_write" for this purpose. 
        in_trigger  <= '0';
        out_trigger <= '0';
        ctrl_start <= '0';
        ctrl_clr   <= '0';
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
            when 22 =>
              avs_readdata <= (31 downto 16 => y_out_reg(15)) & std_logic_vector(y_out_reg);        
           when 24 =>
              avs_readdata <= (31 downto 3 => '0',
                              2 => status_done_sticky,   -- DONE sticky (new)
                              1 => status_busy,
                              0 => status_done);         -- (optional) 1-cycle pulse
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

mac: process(clk, resetn)
  begin
    if resetn = '0' then
      z1 <= (others=>'0'); z2 <= (others=>'0');
      status_busy <= '0'; status_done <= '0';
      mac_s <= IDLE;
      mul_a <= (others=>'0'); mul_b <= (others=>'0');
      mul_p <= (others=>'0'); mul_q28 <= (others=>'0');
      y_acc <= (others=>'0'); t_z1 <= (others=>'0'); t_z2 <= (others=>'0');
      y_out_reg <= (others=>'0');
    elsif rising_edge(clk) then
      status_done <= '0';

      if ctrl_clr = '1' and status_busy = '0' then
        z1 <= (others=>'0'); z2 <= (others=>'0');
      end if;

      -- 16x16 -> 32
      mul_p <= mul_a * mul_b;
      -- arithmetic >>8 (Q2.8); sign-extend top 8 bits
      mul_q28 <= signed( (mul_p(31 downto 24) & mul_p(31 downto 8)) );

      case mac_s is
        when IDLE =>
          status_busy <= '0';
          if ctrl_start = '1' then
            status_busy <= '1';
            -- S1: m1 = b0 * x
            mul_a <= b0; mul_b <= x_in;
            mac_s <= S1_SET;
          end if;

        -- m1
        when S1_SET =>
          mac_s <= S1_USE;
        when S1_USE =>
          y_acc <= z2 + mul_q28;      -- y = z2 + m1
          mul_a <= b1; mul_b <= x_in; -- set m2
          mac_s <= S2_SET;

        -- m2
        when S2_SET =>
          mac_s <= S2_USE;
        when S2_USE =>
          t_z2 <= z1 + mul_q28;       -- z1 + m2
          mul_a <= a1; mul_b <= signed(y_acc(15 downto 0)); -- set m3
          mac_s <= S3_SET;

        -- m3
        when S3_SET =>
          mac_s <= S3_USE;
        when S3_USE =>
          t_z2 <= t_z2 + mul_q28;     -- z1 + m2 + m3
          mul_a <= b2; mul_b <= x_in; -- set m4
          mac_s <= S4_SET;

        -- m4
        when S4_SET =>
          mac_s <= S4_USE;
        when S4_USE =>
          t_z1 <= mul_q28;            -- m4
          mul_a <= a2; mul_b <= signed(y_acc(15 downto 0)); -- set m5
          mac_s <= S5_SET;

        -- m5
        when S5_SET =>
          mac_s <= S5_USE;
        when S5_USE =>
          t_z1 <= t_z1 + mul_q28;     -- m4 + m5
          mac_s <= FIN;

        when FIN =>
          z1 <= t_z1;
          z2 <= t_z2;
          y_out_reg <= signed(y_acc(15 downto 0));  -- 16-bit like software
          status_done <= '1';
          status_busy <= '0';
          mac_s <= IDLE;
      end case;
    end if;
  end process;

  -- connect clock for SISO
  clk_out <= clk;

end architecture mac; -- of gp_custom
