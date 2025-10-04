-- gp_custom_flex_arch.vhd (architecture flex)

architecture flex of gp_custom is
  type buf_memory is array (0 to 7) of std_logic_vector (31 downto 0);

  signal in_buf, out_buf : buf_memory;
  signal in_trigger, out_trigger : std_logic;
  signal in_busy, out_busy : std_logic;

  -- Flexible accelerator registers (Q2.8)
  signal opa, opb      : signed(15 downto 0) := (others => '0');
  signal mul_a, mul_b  : signed(15 downto 0) := (others => '0');
  signal mul_p         : signed(31 downto 0);
  signal mul_q28       : signed(31 downto 0);

  signal acc           : signed(31 downto 0) := (others => '0');
  signal res_reg       : signed(31 downto 0) := (others => '0');

  -- control + handshake
  signal ctrl_mode_mac : std_logic := '0';  -- 0: MUL, 1: MAC
  signal mode_latched  : std_logic := '0';
  signal start_reg     : std_logic := '0';  -- latched START request from SW
  signal start_ack     : std_logic := '0';  -- FSM ack to clear start_reg
  signal ctrl_clr_acc  : std_logic := '0';

  -- status
  signal status_busy   : std_logic := '0';  -- FSM busy
  signal status_done   : std_logic := '0';  -- 1-cycle pulse
  signal status_busy_ro: std_logic;         -- what SW reads as BUSY

  type st_t is (IDLE, MUL, FIN);
  signal st : st_t := IDLE;

begin
  ---------------------------------------------------------------------------
  -- Avalon-MM (unchanged SISO parts; only ctrl regs changed)
  ---------------------------------------------------------------------------
  bus_if : process (resetn, clk)
    variable i: integer range 0 to 7;
  begin
    if resetn = '0' then
      for i in 0 to 7 loop
        out_buf(i) <= (others => '0');
      end loop;
      in_trigger   <= '0';
      out_trigger  <= '0';
      stop_sim     <= '0';
      avs_readdata <= X"55555555";
      start_reg    <= '0';
      ctrl_mode_mac<= '0';
      ctrl_clr_acc <= '0';
    elsif rising_edge(clk) then
      -- consume FSM ack
      if start_ack = '1' then
        start_reg <= '0';
      end if;

      if avs_write = '1' then
        case to_integer(unsigned(avs_addr)) is
          -- SISO buffering (unchanged)
          when 0 to 7  => out_buf(to_integer(unsigned(avs_addr))) <= avs_writedata;
          when 8       => in_trigger  <= avs_writedata(0);
          when 9       => out_trigger <= avs_writedata(0);
          when 12      => stop_sim    <= '1';

          -- Flexible accelerator
          when 16      => opa <= signed(avs_writedata(15 downto 0));
          when 17      => opb <= signed(avs_writedata(15 downto 0));
          when 18      => acc <= signed(avs_writedata); -- ACC preset (Q2.8)
          when 23      =>                            -- CTRL
            if avs_writedata(0) = '1' then
              start_reg <= '1';                      -- latch START request
            end if;
            ctrl_clr_acc  <= avs_writedata(1);
            ctrl_mode_mac <= avs_writedata(2);
          when others   => null;
        end case;

      else
        -- auto-clear one-shots unrelated to the accelerator handshake
        in_trigger   <= '0';
        out_trigger  <= '0';
        ctrl_clr_acc <= '0';

        if avs_read = '1' then
          case to_integer(unsigned(avs_addr)) is
            when 0 to 7 => avs_readdata <= in_buf(to_integer(unsigned(avs_addr)));
            when 8 => avs_readdata  <= (31 downto 1 => '0', 0 => in_trigger);
            when 9 => avs_readdata  <= (31 downto 1 => '0', 0 => out_trigger);
            when 10 => avs_readdata <= (31 downto 1 => '0', 0 => in_busy);
            when 11 => avs_readdata <= (31 downto 1 => '0', 0 => out_busy);
            when 21 => avs_readdata <= std_logic_vector(acc);
            when 22 => avs_readdata <= std_logic_vector(res_reg);
            when 24 => avs_readdata <= (31 downto 2 => '0',
                                         1 => status_busy_ro, 0 => status_done);
            when others => avs_readdata <= X"55555555";
          end case;
        end if;
      end if;
    end if;
  end process;

  -- BUSY visible to SW immediately after writing START
  status_busy_ro <= status_busy or start_reg;

  ---------------------------------------------------------------------------
  -- Input buffer (unchanged)
  ---------------------------------------------------------------------------
  inputs: process(resetn, clk)
    variable i: integer range 0 to 7;
    variable in_counter: integer range 0 to 7;
    variable odd: std_logic;
  begin
    if resetn = '0' then
      for i in 0 to 7 loop
        in_buf(i) <= (others => '0');
      end loop;
      in_busy <= '0';
      siso_req  <= '0';
      in_counter := 0;
      odd := '0';
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
        in_busy <= '1';
        siso_req  <= '1';
        in_counter := 0;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Output buffer (unchanged)
  ---------------------------------------------------------------------------
  outputs: process(resetn, clk)
    variable out_counter: integer range 0 to 7;
    variable odd: std_logic;
  begin
    if resetn = '0' then
      siso_data_out <= (others => '0');
      out_busy  <= '0';
      siso_ready <= '0';
      out_counter := 0;
      odd := '0';
    elsif rising_edge(clk) then
      if out_busy = '1' then
        if odd = '0' then
          siso_data_out <= out_buf(out_counter)(15 downto 0);
          odd := '1';
          siso_ready <= '1';
        else
          siso_data_out <= out_buf(out_counter)(31 downto 16);
          odd := '0';
          siso_ready <= '1';
          if out_counter = 7 then
            out_busy <= '0';
          else
            out_counter := out_counter + 1;
          end if;
        end if;
      else
        siso_ready <= '0';
        if out_trigger = '1' then
          out_busy <= '1';
          out_counter := 0;
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Flexible multiplier/MAC FSM
  ---------------------------------------------------------------------------
  flex_fsm : process(clk, resetn)
  begin
    if resetn = '0' then
      mul_a <= (others => '0'); mul_b <= (others => '0');
      acc <= (others => '0'); res_reg <= (others => '0');
      status_busy <= '0'; status_done <= '0';
      mode_latched <= '0';
      start_ack <= '0';
      st <= IDLE;
    elsif rising_edge(clk) then
      status_done <= '0';
      start_ack   <= '0';

      -- allow clearing ACC when idle
      if (ctrl_clr_acc = '1') and (status_busy = '0') then
        acc <= (others => '0');
      end if;

      case st is
        when IDLE =>
          status_busy <= '0';
          if start_reg = '1' then
            status_busy  <= '1';
            mode_latched <= ctrl_mode_mac;
            mul_a <= opa;
            mul_b <= opb;
            start_ack <= '1';   -- consume the request
            st <= MUL;
          end if;

        when MUL =>
          -- one cycle after latching ops, product is valid
          res_reg <= mul_q28;
          if mode_latched = '1' then
            acc <= acc + mul_q28; -- MAC
          end if;
          st <= FIN;

        when FIN =>
          status_done <= '1';
          status_busy <= '0';
          st <= IDLE;
      end case;
    end if;
  end process;

  -- 16x16 signed multiply and Q2.8 scaling
  mul_p   <= mul_a * mul_b;
  mul_q28 <= resize(mul_p(31 downto 8), 32); -- arithmetic >> 8

  -- pass system clock to TVC
  clk_out <= clk;

end architecture flex;
