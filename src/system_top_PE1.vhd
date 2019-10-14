---------------------------------------------------------------------------------------------------
-- Project          : Mercury+ XU1 Reference Design
-- File description : Top Level
-- File name        : system_top_PE1.vhd
-- Author           : Diana Ungureanu
---------------------------------------------------------------------------------------------------
-- Copyright (c) 2018 by Enclustra GmbH, Switzerland. All rights are reserved. 
-- Unauthorized duplication of this document, in whole or in part, by any means is prohibited
-- without the prior written permission of Enclustra GmbH, Switzerland.
-- 
-- Although Enclustra GmbH believes that the information included in this publication is correct
-- as of the date of publication, Enclustra GmbH reserves the right to make changes at any time
-- without notice.
-- 
-- All information in this document may only be published by Enclustra GmbH, Switzerland.
---------------------------------------------------------------------------------------------------
-- Description:
-- This is a top-level file for Mercury+ XU1 Reference Design
--    
---------------------------------------------------------------------------------------------------
-- File history:
--
-- Version | Date       | Author           | Remarks
-- ------------------------------------------------------------------------------------------------
-- 1.0     | 24.04.2016 | D. Ungureanu     | First released version
-- 2.0     | 20.10.2017 | D. Ungureanu     | Consistency checks
-- 3.0     | 11.06.2018 | D. Ungureanu     | Consistency checks
--
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- libraries
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

---------------------------------------------------------------------------------------------------
-- entity declaration
---------------------------------------------------------------------------------------------------

entity system_top is
  port (
  
  	-------------------------------------------------------------------------------------------
	-- processor system
	-------------------------------------------------------------------------------------------
	
	-- LEDs
	Led2_N							: out	std_logic;

    -- I2C on PL side
    I2c_Scl							: inout	std_logic;
    I2c_Sda							: inout	std_logic;
    
	
	rx_data_n : in STD_LOGIC_VECTOR ( 3 downto 0 );
	rx_data_p : in STD_LOGIC_VECTOR ( 3 downto 0 );
	rx_ref_clk_p : in STD_LOGIC;
	rx_ref_clk_n : in STD_LOGIC;
	rx_sync : out STD_LOGIC;
	rx_sysref : out STD_LOGIC;
	
	                  spi_csn_0: out STD_LOGIC; 
                    spi_clk  : out STD_LOGIC;
                     spi_sdio: inout STD_LOGIC 
	
  );
end system_top;

---------------------------------------------------------------------------------------------------
-- architecture declaration
---------------------------------------------------------------------------------------------------

architecture rtl of system_top is

  component MercuryXU1 is
  port (
    GPIO_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pl_clk1 : out STD_LOGIC;
    pl_resetn0 : out STD_LOGIC;
    rx_core_clk : out STD_LOGIC;
    rx_data_0_n : in STD_LOGIC;
    rx_data_0_p : in STD_LOGIC;
    rx_data_1_n : in STD_LOGIC;
    rx_data_1_p : in STD_LOGIC;
    rx_data_2_n : in STD_LOGIC;
    rx_data_2_p : in STD_LOGIC;
    rx_data_3_n : in STD_LOGIC;
    rx_data_3_p : in STD_LOGIC;
    
    rx_ref_clk_clk_n : in STD_LOGIC_VECTOR ( 0 to 0 );
    rx_ref_clk_clk_p : in STD_LOGIC_VECTOR ( 0 to 0 );
    rx_sync_0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    rx_sysref_0 : in STD_LOGIC;
    spi_clk_i : in STD_LOGIC;
    spi_clk_o : out STD_LOGIC;
    spi_csn_i : in STD_LOGIC_VECTOR ( 7 downto 0 );
    spi_csn_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    spi_sdi_i : in STD_LOGIC;
    spi_sdo_i : in STD_LOGIC;
    spi_sdo_o : out STD_LOGIC
  );
  end component MercuryXU1;
  
  component fmcjesdadc1_spi is
  port (
    spi_csn : in std_logic;
    spi_clk : in  STD_LOGIC;
    spi_mosi : in STD_LOGIC;
    spi_miso : in STD_LOGIC;
    spi_sdio : in STD_LOGIC
  );
  end component fmcjesdadc1_spi;
  
  component ad_sysref_gen is
  port (
    core_clk : in std_logic;
    sysref_en : in  STD_LOGIC;
    sysref_out : out STD_LOGIC
  );
  end component ad_sysref_gen;
-----------------------------------------------------------------------------------------------
-- signals
-----------------------------------------------------------------------------------------------

  signal Rst_N 			: std_logic := '1';
  
  signal Rst            : std_logic := '0';
  signal Clk, rx_core_clk, rx_sysref_bug, spi_clk_buf:std_logic;
  signal RstCnt         : unsigned (15 downto 0) := (others => '0');
  signal LedCount       : unsigned (23 downto 0);  
  
  signal Gpio			: std_logic_vector (7 downto 0);
  signal spi_csn			: std_logic_vector (7 downto 0);
  signal spi_mosi, spi_miso   : std_logic := '0';
  
begin
    rx_sysref <= rx_sysref_bug;
    spi_csn_0 <= spi_csn(0);
    
  spi_clk <=spi_clk_buf;
-----------------------------------------------------------------------------------------------
-- processor system
-----------------------------------------------------------------------------------------------	
    ad_sysref: component ad_sysref_gen
    port map (
        core_clk => rx_core_clk,
        sysref_en => Gpio(0),
        sysref_out => rx_sysref_bug
    );
    spi: component fmcjesdadc1_spi
    port map (
        spi_csn => spi_csn(0),
        spi_clk => spi_clk_buf,
        spi_mosi => spi_mosi,
        spi_miso => spi_miso,
        spi_sdio => spi_sdio
    );
    
	MercuryXU1_i: component MercuryXU1
       port map (
        GPIO_tri_o(7 downto 0) => Gpio(7 downto 0),
        pl_clk1 => Clk,
        pl_resetn0 => Rst_N,
        rx_core_clk => rx_core_clk,
        rx_data_0_n => rx_data_n(0),
        rx_data_0_p => rx_data_p(0),
        rx_data_1_n  => rx_data_n(1),
        rx_data_1_p => rx_data_p(1),
        rx_data_2_n  => rx_data_n(2),
        rx_data_2_p => rx_data_p(2),
        rx_data_3_n  => rx_data_n(3),
        rx_data_3_p  => rx_data_p(3),
        
        rx_ref_clk_clk_n(0) => rx_ref_clk_n,
        rx_ref_clk_clk_p(0) => rx_ref_clk_p,
        rx_sync_0(0) => rx_sync,
        rx_sysref_0 => rx_sysref_bug,
        spi_clk_i => spi_clk_buf,
        spi_clk_o => spi_clk_buf,
        spi_csn_i => spi_csn,
        spi_csn_o => spi_csn,
        spi_sdi_i => spi_miso,
        spi_sdo_i => spi_mosi,
        spi_sdo_o => spi_mosi
      );

    ------------------------------------------------------------------------------------------------
    --  Clock and Reset
    ------------------------------------------------------------------------------------------------ 

    process (Clk)
    begin
        if rising_edge (Clk) then
            if (not RstCnt) = 0 then
                Rst         <= '0';
            else
                Rst         <= '1';
                RstCnt      <= RstCnt + 1;
            end if;
        end if;
    end process;
    
    ------------------------------------------------------------------------------------------------
    -- Blinking LED counter & LED assignment
    ------------------------------------------------------------------------------------------------
   
    process (Clk)
    begin
        if rising_edge (Clk) then
            if Rst = '1' then
                LedCount    <= (others => '0');
            else
                LedCount <= LedCount + 1;
            end if;
        end if;
    end process;
    
    Led2_N <= LedCount(23);	
--    Led2_N <= Gpio(2);


    I2c_Sda <= 'Z';
    I2c_Scl <= 'Z';
	
	-- --LVDS example
	-- -- note: only diff inputs supported in HD banks
	--LDVS_in : IBUFDS 
	--port map (
	--	O  => IO_B48_L5_HDGC_in,
	--	I  => IO_B48_L5_HDGC_E12_P,
	--	IB => IO_B48_L5_HDGC_D12_N
    --);
	
end rtl;


---------------------------------------------------------------------------------------------------
-- eof
---------------------------------------------------------------------------------------------------

