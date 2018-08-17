-------------------------------------------------------------------------------
--
-- FPGA Videopac
--
-- $Id: zefant_xs3_vp.vhd,v 1.18 2007/04/07 10:49:05 arnim Exp $
-- $Name: videopac_rel_1_0 $
--
-- Toplevel of the Spartan3 port for Simple Solutions' Zefant-XS3 board.
--   http://zefant.de/
--
-- Ported to ZX-Uno by yomboprime 2018
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2007, Arnim Laeuger (arnim.laeuger@gmx.net)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;

entity zxuno_xs6_vp is
  port (

    -- Clock oscillator
    clk50mhz                     : in    std_logic;
    
    -- SD card
    sd_clk                      : out    std_logic;
    sd_mosi                     : out    std_logic;
    sd_miso                     : in    std_logic;
    sd_cs_n                     : out    std_logic;
    
    -- SRAM
    sram_addr                    : out   std_logic_vector(18 downto 0);
    sram_data                    : inout std_logic_vector(7 downto 0);
    sram_we_n                    : out   std_logic;


    -- User Interface
    testled                      : out   std_logic_vector(1 downto 0);
    
    --debugled                     : out   std_logic_vector(7 downto 0);

    r                    : out   std_logic_vector(5 downto 0);
    g                    : out   std_logic_vector(5 downto 0);
    b                    : out   std_logic_vector(5 downto 0);
    hsync                : out   std_logic;
    --vid_psave_n              : out   std_logic;
    --vid_sync_n               : out   std_logic;
    vsync                : out   std_logic;
    
    clkps2                : inout   std_logic;
    dataps2               : inout   std_logic;
    
    joy_data              : in   std_logic;
    joy_load_n            : out   std_logic;
    joy_clk               : out   std_logic;
    
    audioL                : out std_logic;
    audioR                : out std_logic

  );
end zxuno_xs6_vp;


library ieee;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.tech_comp_pack.vp_por;
use work.vp_console_comp_pack.vp_console;
--use work.board_misc_comp_pack.mc_ctrl;
use work.board_misc_comp_pack.dblscan;
use work.i8244_col_pack.all;
use work.board_misc_comp_pack.vp_keymap;
use work.ps2_keyboard_comp_pack.ps2_keyboard_interface;
use work.i8244_col_pack.all;

--use work.joydecoder;

architecture struct of zxuno_xs6_vp is

  -----------------------------------------------------------------------------
  -- Include multicard controller
  --
  -- Settings the following constant to true, includes the multicard
  -- controller. It supports selecting several cartridge images on SR1 by
  -- software.
  -- If it's set to false, one single cartridge image will be expected at SR1.
  --
  constant multi_card_c : boolean := false;
  --
  -----------------------------------------------------------------------------

  component zxuno_xs6_pll
    port (
      clkin_i    : in  std_logic;
      locked_o   : out std_logic;
      clk_43m_o  : out std_logic;
      clk_21m5_o : out std_logic
    );
  end component;

  component rom_vp
    port(
      --Clk : in  std_logic;
      A   : in  std_logic_vector(12 downto 0);
      D   : out std_logic_vector(7 downto 0)
    );
  end component;
  
  component joydecoder
    port (
      clk: in  std_logic;
      joy_data: in  std_logic;
      joy_clk: out  std_logic;
      joy_load_n: out  std_logic;
      joy1up: out  std_logic;
      joy1down: out  std_logic;
      joy1left: out  std_logic;
      joy1right: out  std_logic;
      joy1fire1: out  std_logic;
      joy1fire2: out  std_logic;
      joy1fire3: out  std_logic;
      joy1start: out  std_logic;
      joy2up: out  std_logic;
      joy2down: out  std_logic;
      joy2left: out  std_logic;
      joy2right: out  std_logic;
      joy2fire1: out  std_logic;
      joy2fire2: out  std_logic;
      joy2fire3: out  std_logic;
      joy2start: out  std_logic
    );
  end component;


  component rom_selector
    port (
      clk: in  std_logic;
      sd_clk: out    std_logic;
      sd_mosi: out    std_logic;
      sd_miso: in    std_logic;
      sd_cs_n: out    std_logic;
      sram_addr: out std_logic_vector(18 downto 0);
      sram_data: inout std_logic_vector(7 downto 0);
      sram_we_n: out  std_logic;
      vp_addr: in std_logic_vector(12 downto 0);
      vp_data: out std_logic_vector(7 downto 0);
      vp_en_n: in  std_logic;
      vp_rst_n: out std_logic;
      sd_initialized: out std_logic;
      doLoadRom: in  std_logic;
      selectedROM: in std_logic_vector(15 downto 0);
      currentROM: out std_logic_vector(15 downto 0)--;
      --debugled: out std_logic_vector(7 downto 0)
    );
  end component;

  component osd
    port (
      clk: in  std_logic;
      hpos: in std_logic_vector(8 downto 0);
      vpos: in std_logic_vector(8 downto 0);
      out_r: out std_logic_vector(5 downto 0);
      out_g: out std_logic_vector(5 downto 0);
      out_b: out std_logic_vector(5 downto 0);
      out_alpha: out std_logic;
      sd_initialized: in std_logic;
      currentROM: in std_logic_vector(15 downto 0);
      selectedROM: out std_logic_vector(15 downto 0);
      doLoadRom: out std_logic;
      key_released: in  std_logic;
      key_ready: in  std_logic;
      key_ascii: in std_logic_vector(7 downto 0)
    );
  end component;

  component dac
    port(
      Clk : in  std_logic;
      Reset : in  std_logic;
      DACout: out std_logic;
      DACin : in  std_logic_vector(8 downto 0)
    );
  end component;

  signal dcm_locked_s   : std_logic;
  signal reset_n_s,
         reset_s        : std_logic;
  signal reset_video_s   : std_logic;
  signal reset_video_n_s   : std_logic;
  signal por_n_s        : std_logic;
  signal clk_43m_s      : std_logic;
  signal clk_21m5_s     : std_logic;

  signal glob_res_n_s   : std_logic;
  
  signal control_rst_n    : std_logic;

  -- CPU clock = PLL clock 21.5 MHz / 4
  constant cnt_cpu_c    : unsigned(1 downto 0) := to_unsigned(3, 2);
  -- VDC clock = PLL clock 21.5 MHz / 3
  -- note: VDC core runs with double frequency than compared with 8244 chip
  constant cnt_vdc_c    : unsigned(1 downto 0) := to_unsigned(2, 2);
  -- VGA clock = PLL clock 43 MHz / 3 (2x VDC clock)
  constant cnt_vga_c    : unsigned(1 downto 0) := to_unsigned(2, 2);
  --
  signal cnt_cpu_q      : unsigned(1 downto 0);
  signal cnt_vdc_q      : unsigned(1 downto 0);
  signal cnt_vga_q      : unsigned(1 downto 0);
  signal clk_cpu_en_s,
         clk_vdc_en_s,
         clk_vga_en_q   : std_logic;

  signal cart_a_s       : std_logic_vector(11 downto 0);
  signal rom_a_s        : std_logic_vector(12 downto 0);
  
  signal cart_d_s,
         cart_d_from_vp_s: std_logic_vector( 7 downto 0);
  signal cart_bs0_s,
         cart_bs1_s,
         cart_psen_n_s  : std_logic;

   signal but_up_s,
          but_down_s,
          but_left_s,
          but_right_s,
          but_action_s    : std_logic_vector( 1 downto 0);

    signal but_up_s0,
           but_down_s0,
           but_left_s0,
           but_right_s0,
           but_action_s0,
           but_up_s1,
           but_down_s1,
           but_left_s1,
           but_right_s1,
           but_action_s1: std_logic;

  signal rgb_r_s,
         rgb_g_s,
         rgb_b_s,
         rgb_l_s        : std_logic;
  signal rgb_hsync_n_s,
         rgb_hsync_s,
         rgb_vsync_n_s,
         rgb_vsync_s    : std_logic;
  signal vga_r_s,
         vga_g_s,
         vga_b_s,
         vga_l_s        : std_logic;
  signal vga_hsync_s,
         vga_vsync_s    : std_logic;
--   signal blank_s        : std_logic;

  signal snd_vec_s      : std_logic_vector( 3 downto 0);
--   signal pcm_audio_s    : signed(8 downto 0);

	signal audio_s    : std_logic;

--   signal aud_bit_clk_s  : std_logic;

  signal hpos: std_logic_vector(8 downto 0);
  signal vpos: std_logic_vector(8 downto 0);
  signal oddLine: std_logic;

  signal keyb_dec_s      : std_logic_vector( 6 downto 1);
  signal keyb_enc_s      : std_logic_vector(14 downto 7);
  signal rx_data_ready_s : std_logic;
  signal rx_ascii_s      : std_logic_vector( 7 downto 0);
  signal rx_released_s   : std_logic;
  signal rx_extended_s     : std_logic;
  signal rx_read_s       : std_logic;

  signal cart_cs_s,
         cart_cs_n_s,
         cart_wr_n_s     : std_logic;
--  signal extmem_a_s      : std_logic_vector(18 downto 0);

  signal gnd8_s : std_logic_vector(7 downto 0);
  
  signal sd_initialized: std_logic;
  signal osd_r: std_logic_vector(5 downto 0);
  signal osd_g: std_logic_vector(5 downto 0);
  signal osd_b: std_logic_vector(5 downto 0);
  signal osd_alpha: std_logic;
  signal currentROM: std_logic_vector(15 downto 0);
  signal selectedROM: std_logic_vector(15 downto 0);
  signal doLoadRom: std_logic;

begin

	audioL <= audio_s;
	audioR <= audio_s;
	
	gnd8_s <= (others => '0');

	-- Reset
	glob_res_n_s <= por_n_s and dcm_locked_s and control_rst_n;
	reset_n_s <= glob_res_n_s and dcm_locked_s;-- and
               --(but_tl_s(0) or but_tr_s(0));
	reset_s   <= not reset_n_s;
	
	reset_video_s <= por_n_s and dcm_locked_s;
	reset_video_n_s <= not reset_video_s;
	
	--
	-- Rom management
	--

    romsel : rom_selector
    port map (
      clk => clk_21m5_s,
      sd_clk => sd_clk,
      sd_mosi => sd_mosi,
      sd_miso => sd_miso,
      sd_cs_n => sd_cs_n,
      sram_addr => sram_addr,
      sram_data => sram_data,
      sram_we_n => sram_we_n,
      vp_addr => rom_a_s,
      vp_data => cart_d_s,
      vp_en_n => cart_psen_n_s,
      vp_rst_n => control_rst_n,
      sd_initialized => sd_initialized,
      doLoadRom => doLoadRom,
      selectedROM => selectedROM,
      currentROM => currentROM--,
      --debugled => debugled
    );
    
    testled(0) <= not sd_initialized;
    testled(1) <= '1';
    
  
  -----------------------------------------------------------------------------
  -- Power-on reset module
  -----------------------------------------------------------------------------
  por_b : vp_por
    generic map (
      delay_g     => 3,
      cnt_width_g => 2
    )
    port map (
      clk_i   => clk_21m5_s,
      por_n_o => por_n_s
    );


  -----------------------------------------------------------------------------
  -- The PLL
  -----------------------------------------------------------------------------
  pll_b : zxuno_xs6_pll
    port map (
      clkin_i    => clk50mhz,
      locked_o   => dcm_locked_s,
      clk_43m_o  => clk_43m_s,
      clk_21m5_o => clk_21m5_s
    );

  -----------------------------------------------------------------------------
  -- Process clk_en
  --
  -- Purpose:
  --   Generates the CPU and VDC clock enables.
  --
  clk_en: process (clk_21m5_s, reset_video_s)
  begin
    if reset_video_s = '0' then
      cnt_cpu_q    <= cnt_cpu_c;
      cnt_vdc_q    <= cnt_vdc_c;

    elsif rising_edge(clk_21m5_s) then
      if clk_cpu_en_s = '1' then
        cnt_cpu_q <= cnt_cpu_c;
      else
        cnt_cpu_q <= cnt_cpu_q - 1;
      end if;
      --
      if clk_vdc_en_s = '1' then
        cnt_vdc_q <= cnt_vdc_c;
      else
        cnt_vdc_q <= cnt_vdc_q - 1;
      end if;
    end if;
  end process clk_en;
  --
  clk_cpu_en_s <= '1' when cnt_cpu_q = 0 else '0';
  clk_vdc_en_s <= '1' when cnt_vdc_q = 0 else '0';
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process vga_clk_en
  --
  -- Purpose:
  --   Generates the VGA clock enable.
  --
  vga_clk_en: process (clk_43m_s, reset_video_s)
  begin
    if reset_video_s = '0' then
      cnt_vga_q    <= cnt_vga_c;
      clk_vga_en_q <= '0';
    elsif rising_edge(clk_43m_s) then
      if cnt_vga_q = 0 then
        cnt_vga_q    <= cnt_vga_c;
        clk_vga_en_q <= '1';
      else
        cnt_vga_q    <= cnt_vga_q - 1;
        clk_vga_en_q <= '0';
      end if;
    end if;
  end process vga_clk_en;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- The Videopac console
  -----------------------------------------------------------------------------
  vp_console_b : vp_console
    generic map (
      is_pal_g => 1
    )
    port map (
      clk_i          => clk_21m5_s,
      clk_cpu_en_i   => clk_cpu_en_s,
      clk_vdc_en_i   => clk_vdc_en_s,
      res_n_i        => reset_n_s,
      cart_cs_o      => cart_cs_s,
      cart_cs_n_o    => cart_cs_n_s,
      cart_wr_n_o    => cart_wr_n_s,
      cart_a_o       => cart_a_s,
      cart_d_i       => cart_d_s,
      cart_d_o       => cart_d_from_vp_s,
      cart_bs0_o     => cart_bs0_s,
      cart_bs1_o     => cart_bs1_s,
      cart_psen_n_o  => cart_psen_n_s,
      cart_t0_i      => gnd8_s(0),
      cart_t0_o      => open,
      cart_t0_dir_o  => open,
      -- idx = 0 : left joystick
      -- idx = 1 : right joystick
      joy_up_n_i     => but_up_s,
      joy_down_n_i   => but_down_s,
      joy_left_n_i   => but_left_s,
      joy_right_n_i  => but_right_s,
      joy_action_n_i => but_action_s,
      keyb_dec_o     => keyb_dec_s,
      keyb_enc_i     => keyb_enc_s,
      r_o            => rgb_r_s,
      g_o            => rgb_g_s,
      b_o            => rgb_b_s,
      l_o            => rgb_l_s,
      hsync_n_o      => rgb_hsync_n_s,
      vsync_n_o      => rgb_vsync_n_s,
      hbl_o          => open,
      vbl_o          => open,
      snd_o          => open,
      snd_vec_o      => snd_vec_s,
	  hpos_o         => hpos,
	  vpos_o         => vpos
    );

    
    --
    -- Audio dac
    --
    dac1 : dac
    port map (
      Clk => clk_21m5_s,
      DACout => audio_s,
      DACin => '0' & snd_vec_s & "0000",
      Reset => reset_s
    );
    
  -----------------------------------------------------------------------------
  -- Multicard controller
  -----------------------------------------------------------------------------
--  use_mc: if multi_card_c generate
--    mc_ctrl_b : mc_ctrl
--      port map (
--        clk_i       => clk_21m5_s,
--        reset_n_i   => glob_res_n_s,
--        cart_a_i    => cart_a_s,
--        cart_d_i    => cart_d_from_vp_s,
--        cart_cs_i   => cart_cs_s,
--        cart_cs_n_i => cart_cs_n_s,
--        cart_wr_n_i => cart_wr_n_s,
--        cart_bs0_i  => cart_bs0_s,
--        cart_bs1_i  => cart_bs1_s,
--        extmem_a_o  => extmem_a_s
--      );
--  end generate;
--  no_mc: if not multi_card_c generate
--    extmem_a_s <= (others => '0');
--  end generate;


  -----------------------------------------------------------------------------
  -- Assemble the standard cartridge ROM address bus
  -----------------------------------------------------------------------------
  rom_a_s <= ( 0 => cart_a_s( 0),
               1 => cart_a_s( 1),
               2 => cart_a_s( 2),
               3 => cart_a_s( 3),
               4 => cart_a_s( 4),
               5 => cart_a_s( 5),
               6 => cart_a_s( 6),
               7 => cart_a_s( 7),
               8 => cart_a_s( 8),
               9 => cart_a_s( 9),
              10 => cart_a_s(11),
              11 => cart_bs0_s,
              12 => cart_bs1_s);

    --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- VGA Scan Doubler
  -----------------------------------------------------------------------------
  rgb_hsync_s <= not rgb_hsync_n_s;
  rgb_vsync_s <= not rgb_vsync_n_s;
  --
  dblscan_b : dblscan
    port map (
      RGB_R_IN   => rgb_r_s,
      RGB_G_IN   => rgb_g_s,
      RGB_B_IN   => rgb_b_s,
      RGB_L_IN   => rgb_l_s,
      HSYNC_IN   => rgb_hsync_s,
      VSYNC_IN   => rgb_vsync_s,
      VGA_R_OUT  => vga_r_s,
      VGA_G_OUT  => vga_g_s,
      VGA_B_OUT  => vga_b_s,
      VGA_L_OUT  => vga_l_s,
      HSYNC_OUT  => vga_hsync_s,
      VSYNC_OUT  => vga_vsync_s,
      BLANK_OUT  => open, --blank_s,
      CLK_RGB    => clk_21m5_s,
      CLK_EN_RGB => clk_vdc_en_s,
      CLK_VGA    => clk_43m_s,
      CLK_EN_VGA => clk_vga_en_q,
      RESET_N_I  => reset_video_s,
      ODD_LINE   => oddLine
    );
--

  --
  -- OSD module
  --
  osd1 : osd
    port map (
      clk => clk_43m_s,
      hpos => hpos,
      vpos => vpos,
      out_r => osd_r,
      out_g => osd_g,
      out_b => osd_b,
      out_alpha => osd_alpha,
      sd_initialized => sd_initialized,
      currentROM => currentROM,
      selectedROM => selectedROM,
      doLoadRom => doLoadRom,
      key_released => rx_released_s,
      key_ready => rx_data_ready_s,
      key_ascii => rx_ascii_s
    );



--  vid_clk   <= clk_vga_en_q;
  vga_rgb: process (clk_43m_s, reset_video_s)
    variable col_v : natural range 0 to 15;
  begin
    if reset_video_s ='0' then
      r <= (others => '0');
      g <= (others => '0');
      b <= (others => '0');
      hsync <= '1';
      vsync <= '1';
      --vid_blank <= '1';
    elsif rising_edge(clk_43m_s) then
      if clk_vga_en_q = '1' then
        col_v := to_integer(unsigned'(vga_l_s & vga_r_s & vga_g_s & vga_b_s));

		if ( osd_alpha = '1' ) then
 			r <= osd_r;
 			g <= osd_g;
 			b <= osd_b;
 		else
			r <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(r_c), 6));
			g <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(g_c), 6));
			b <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(b_c), 6));
		end if;

        hsync <= not vga_hsync_s;
        vsync <= not vga_vsync_s;
        --vid_blank <= not blank_s;
        
        
        -- Scanlines
		--if oddLine = '1' then
		--	r <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(r_c), 6));
		--	g <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(g_c), 6));
		--	b <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(b_c), 6));
		--else
		--	r <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(r_c), 6)) and "110000";
		--	g <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(g_c), 6)) and "110000";
		--	b <= std_logic_vector(to_unsigned(full_rgb_table_c(col_v)(b_c), 6)) and "110000";
		--end if;
        
        
      end if;
    end if;
  end process vga_rgb;

  --oddLine <= vpos(0);
  
  -- Joysticks
  joys : joydecoder
    port map (
      clk => clk_21m5_s,
      joy_data => joy_data,
      joy_clk => joy_clk,
      joy_load_n => joy_load_n,
      joy1up => but_up_s1,
      joy1down => but_down_s1,
      joy1left => but_left_s1,
      joy1right => but_right_s1,
      joy1fire1 => but_action_s1,
      joy1fire2 => open,
      joy1fire3 => open,
      joy1start => open,
      joy2up => but_up_s0,
      joy2down => but_down_s0,
      joy2left => but_left_s0,
      joy2right => but_right_s0,
      joy2fire1 => but_action_s0,
      joy2fire2 => open,
      joy2fire3 => open,
      joy2start => open
    );

	but_up_s(0) <= but_up_s0;
	but_down_s(0) <= but_down_s0;
	but_left_s(0) <= but_left_s0;
	but_right_s(0) <= but_right_s0;
	but_action_s(0) <= but_action_s0;
	
	but_up_s(1) <= but_up_s1;
	but_down_s(1) <= but_down_s1;
	but_left_s(1) <= but_left_s1;
	but_right_s(1) <= but_right_s1;
	but_action_s(1) <= but_action_s1;

  -----------------------------------------------------------------------------
  -- Keyboard components
  -----------------------------------------------------------------------------
  vp_keymap_b : vp_keymap
    port map (
      clk_i           => clk_21m5_s,
      res_n_i         => reset_video_s,
      keyb_dec_i      => keyb_dec_s,
      keyb_enc_o      => keyb_enc_s,
      rx_data_ready_i => rx_data_ready_s,
      rx_ascii_i      => rx_ascii_s,
      rx_released_i   => rx_released_s,
      rx_read_o       => rx_read_s
    );
  --
  ps2_keyboard_b : ps2_keyboard_interface
    generic map (
      TIMER_60USEC_VALUE_PP => 1290, -- Number of sys_clks for 60usec
      TIMER_60USEC_BITS_PP  =>   11, -- Number of bits needed for timer
      TIMER_5USEC_VALUE_PP  =>  107, -- Number of sys_clks for debounce
      TIMER_5USEC_BITS_PP   =>    7  -- Number of bits needed for timer
    )
    port map (
      clk             => clk_21m5_s,
      reset           => reset_video_n_s,
      ps2_clk         => clkps2,
      ps2_data        => dataps2,
      rx_extended     => rx_extended_s,
      rx_released     => rx_released_s,
      rx_shift_key_on => open,
      rx_ascii        => rx_ascii_s,
      rx_data_ready   => rx_data_ready_s,
      rx_read         => rx_read_s,
      tx_data         => gnd8_s,
      tx_write        => gnd8_s(0),
      tx_write_ack    => open,
      tx_error_no_keyboard_ack => open
    );

end struct;
