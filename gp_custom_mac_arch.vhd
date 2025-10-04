-------------------------------------------------------------------------------
-- File         : gp_custom_mac_arch.vhd
-- Description  : I/O buffer architecture for gp_custom with hardware biquad
--                filter
-- Author       : Luis Moreno and Lucas van Zutphen
-- Creation date: September 31, 2025
-------------------------------------------------------------------------------

architecture mac of gp_custom is

  type buf_memory is array (0 to 7) of std_logic_vector (31 downto 0);

  signal in_buf, out_buf : buf_memory;
  signal in_trigger, out_trigger : std_logic;
  signal in_busy, out_busy : std_logic;

  -- Coeffs, I/O sample, control/status
  signal b0, b1, b2, a1, a2 : signed(15 downto 0) := (others => '0');
  signal x_in               : signed(15 downto 0) := (others => '0');
  signal y_out_reg          : signed(15 downto 0) := (others => '0');

  signal ctrl_start, ctrl_clr : std_logic := '0';
  signal status_done          : std_logic := '0';
  signal status_busy          : std_logic := '0';

  -- IIR states (wider to avoid overflow in Q2.8 math)
  signal z1, z2 : signed(31 downto 0) := (others => '0');

  -- Multiplier interface (operands are registered; product is combinational)
  signal mul_a, mul_b : signed(15 downto 0) := (others => '0');
  signal mul_p        : signed(31 downto 0);  -- 16x16 -> 32
  signal mul_q28      : signed(31 downto 0);  -- (a*b) >> 8, arith

  -- Simple 2-phase-per-multiply FSM to account for mul latency
  type mac_state_t is (
    IDLE,
    S1_SET, S1_USE,   -- m1 = b0*x ; y   = z2 + m1
    S2_SET, S2_USE,   -- m2 = b1*x ; tz2 = z1 + m2
    S3_SET, S3_USE,   -- m3 = a1*y ; tz2 = tz2 + m3
    S4_SET, S4_USE,   -- m4 = b2*x ; tz1 = m4
    S5_SET, S5_USE,   -- m5 = a2*y ; tz1 = tz1 + m5
    FIN
  );
  signal mac_s : mac_state_t := IDLE;

  -- Scratch registers
  signal y_acc       : signed(31 downto 0) := (others => '0');
  signal t_z1, t_z2  : signed(31 downto 0) := (others => '0');

begin
  ---------------------------------------------------------------------------
  -- Avalon-MM slave: original buffering logic kept as-is
  ---------------------------------------------------------------------------
  bus_if : process (resetn, clk)
    variable i : integer range 0 to 7;
  begin
    if resetn = '0' then
      for i in 0 to 7 loop
        out_buf(i) <= (others => '0');
      end loop;
      in_trigger   <= '0';
      out_trigger  <= '0';
      stop_sim     <= '0';
      avs_readdata <= X"55555555";
    elsif rising_edge(clk) then
      if avs_write = '1' then
        case to_integer(unsigned(avs_addr)) is
          when 0 to 7 =>  out_buf(to_integer(unsigned(avs_addr))) <= avs_writedata;
          when 8     =>  in_trigger  <= avs_writedata(0);
          when 9     =>  out_trigger <= avs_writedata(0);
          when 12    =>  stop_sim    <= '1';
          -- MAC registers
          when 16    =>  b0    <= signed(avs_writedata(15 downto 0));
          when 17    =>  b1    <= signed(avs_writedata(15 downto 0));
          when 18    =>  b2    <= signed(avs_writedata(15 downto 0));
          when 19    =>  a1    <= signed(avs_writedata(15 downto 0));
          when 20    =>  a2    <= signed(avs_writedata(15 downto 0));
          when 21    =>  x_in  <= signed(avs_writedata(15 downto 0));
          when 23    =>  -- CTRL: bit0 START, bit1 CLR
            ctrl_start <= avs_writedata(0);
            ctrl_clr   <= avs_writedata(1);
          when others => null;
        end case;
      else
        -- auto-clear one-shot controls/triggers when not writing
        in_trigger  <= '0';
        out_trigger <= '0';
        ctrl_start  <= '0';
        ctrl_clr    <= '0';
        if avs_read = '1' then
          case to_integer(unsigned(avs_addr)) is
            when 0 to 7 => avs_readdata <= in_buf(to_integer(unsigned(avs_addr)));
            when 8     => avs_readdata <= (31 downto 1 => '0', 0 => in_trigger);
            when 9     => avs_readdata <= (31 downto 1 => '0', 0 => out_trigger);
            when 10    => avs_readdata <= (31 downto 1 => '0', 0 => in_busy);
            when 11    => avs_readdata <= (31 downto 1 => '0', 0 => out_busy);
            when 22    => avs_readdata <= std_logic_vector(resize(y_out_reg, 32));     -- sign-extend
            when 24    => avs_readdata <= (31 downto 2 => '0', 1 => status_busy, 0 => status_done);
            when others=> avs_readdata <= X"55555555";
          end case;
        end if;
      end if;
    end if;
  end process;

  -- Input FIFO-like buffer to TVC (unchanged)
  inputs : process (resetn, clk)
    variable i           : integer range 0 to 7;
    variable in_counter  : integer range 0 to 7;
    variable odd         : std_logic;
  begin
    if resetn = '0' then
      for i in 0 to 7 loop
        in_buf(i) <= (others => '0');
      end loop;
      in_busy     <= '0';
      siso_req    <= '0';
      in_counter  := 0;
      odd         := '0';
    elsif rising_edge(clk) then
      if in_busy = '1' then
        if odd = '0' then
          in_buf(in_counter)(15 downto 0) <= siso_data_in;
          odd := '1';
        else
          in_buf(in_counter)(31 downto 16) <= siso_data_in;
          odd := '0';
          if in_counter = 7 then
            siso_req <= '0';
            in_busy  <= '0';
          else
            in_counter := in_counter + 1;
          end if;
        end if;
      elsif in_trigger = '1' then
        in_busy    <= '1';
        siso_req   <= '1';
        in_counter := 0;
      end if;
    end if;
  end process;

  -- Output FIFO-like buffer to TVC (unchanged)
  outputs : process (resetn, clk)
    variable out_counter : integer range 0 to 7;
    variable odd         : std_logic;
  begin
    if resetn = '0' then
      siso_data_out <= (others => '0');
      out_busy      <= '0';
      siso_ready    <= '0';
      out_counter   := 0;
      odd           := '0';
    elsif rising_edge(clk) then
      if out_busy = '1' then
        if odd = '0' then
          siso_data_out <= out_buf(out_counter)(15 downto 0);
          odd           := '1';
          siso_ready    <= '1';
        else
          siso_data_out <= out_buf(out_counter)(31 downto 16);
          odd           := '0';
          siso_ready    <= '1';
          if out_counter = 7 then
            out_busy <= '0';
          else
            out_counter := out_counter + 1;
          end if;
        end if;
      else
        siso_ready <= '0';
        if out_trigger = '1' then
          out_busy    <= '1';
          out_counter := 0;
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- MAC FSM: one result per START, Q2.8 scaling (>>8) on each multiply
  ---------------------------------------------------------------------------
  mac : process (clk, resetn)
  begin
    if resetn = '0' then
      z1 <= (others => '0');  z2 <= (others => '0');
      status_busy <= '0';     status_done <= '0';
      mac_s <= IDLE;
      mul_a <= (others => '0'); mul_b <= (others => '0');
      y_acc <= (others => '0'); t_z1  <= (others => '0'); t_z2 <= (others => '0');
      y_out_reg <= (others => '0');
    elsif rising_edge(clk) then
      status_done <= '0'; -- default: pulse for one cycle in FIN

      -- state clear between operations
      if (ctrl_clr = '1') and (status_busy = '0') then
        z1 <= (others => '0');
        z2 <= (others => '0');
      end if;

      case mac_s is
        when IDLE =>
          status_busy <= '0';
          if ctrl_start = '1' then
            status_busy <= '1';
            mul_a <= b0;  mul_b <= x_in; -- m1 = b0*x
            mac_s <= S1_SET;
          end if;

        when S1_SET => mac_s <= S1_USE;
        when S1_USE =>
          y_acc <= z2 + mul_q28; -- y = z2 + m1
          mul_a <= b1;  mul_b <= x_in; -- m2 = b1*x
          mac_s <= S2_SET;

        when S2_SET => mac_s <= S2_USE;
        when S2_USE =>
          t_z2 <= z1 + mul_q28; -- tz2 = z1 + m2
          mul_a <= a1;  mul_b <= signed(y_acc(15 downto 0)); -- m3 = a1*y
          mac_s <= S3_SET;

        when S3_SET => mac_s <= S3_USE;
        when S3_USE =>
          t_z2 <= t_z2 + mul_q28; -- tz2 += m3
          mul_a <= b2;  mul_b <= x_in; -- m4 = b2*x
          mac_s <= S4_SET;

        when S4_SET => mac_s <= S4_USE;
        when S4_USE =>
          t_z1 <= mul_q28; -- tz1 = m4
          mul_a <= a2;  mul_b <= signed(y_acc(15 downto 0)); -- m5 = a2*y
          mac_s <= S5_SET;

        when S5_SET => mac_s <= S5_USE;
        when S5_USE =>
          t_z1 <= t_z1 + mul_q28; -- tz1 += m5
          mac_s <= FIN;

        when FIN =>
          z1 <= t_z1; -- commit states
          z2 <= t_z2;
          y_out_reg   <= signed(y_acc(15 downto 0)); -- 16-bit result (Q2.8)
          status_done <= '1';
          status_busy <= '0';
          mac_s <= IDLE;
      end case;
    end if;
  end process;

  -- 16x16 signed multiply and Q2.8 scaling (combinational)
  mul_p   <= mul_a * mul_b;
  mul_q28 <= resize(mul_p(31 downto 8), 32); -- arithmetic >> 8

  -- pass system clock to TVC
  clk_out <= clk;

end architecture mac;
