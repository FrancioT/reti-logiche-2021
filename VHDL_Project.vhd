-- Progetto di Francesco Maria Tranquillo
-- Matricola: 935612
-- Codice persona: 10674562

--------------------------
-- FlipFlop T
--------------------------

library ieee;
use ieee.STD_LOGIC_1164.ALL;

entity FFT is
    port(
        in_t: in std_logic;
        clk, rst: in std_logic;
        out1: out std_logic
    );
end FFT;

architecture behavioral of FFT is
    signal a: std_logic;
begin
    process(clk, rst)
    begin
        if rst = '1' 
           then a <= '0';
        elsif rising_edge(clk) 
           then if in_t = '1'
                then a <= not a;
                end if;
        end if;
    end process;
    out1 <= a;
end behavioral;

--------------------------
-- FlipFlop D
--------------------------

library ieee;
use ieee.STD_LOGIC_1164.ALL;

entity FlipFlop is
    port(
        in1: in std_logic;
        clk, rst: in std_logic;
        out1: out std_logic
    );
end FlipFlop;

architecture behavioral of FlipFlop is
begin 
    process(clk, rst)
    begin
        if rst = '1' 
           then out1 <= '0';
        elsif rising_edge(clk) 
           then out1 <= in1;
        end if;
    end process;
end behavioral;

--------------------------
-- Latch
--------------------------

library ieee;
use ieee.STD_LOGIC_1164.ALL;

entity Latch is
    port(
        in1: in std_logic;
        clk, rst: in std_logic;
        out1: out std_logic
    );
end Latch;

architecture behavioral of Latch is
begin 
    process(clk, rst, in1)
    begin
        if rst = '1' 
           then out1 <= '0';
        elsif clk = '1' 
           then out1 <= in1;
        end if;
    end process;
end behavioral;

--------------------------
-- FlipFlop T con set e reset asincroni
--------------------------

library ieee;
use ieee.STD_LOGIC_1164.ALL;

entity FFTSR is
    port(
        in_t: in std_logic;
        clk, set, rst: in std_logic;
        out1: out std_logic
    );
end FFTSR;

architecture behavioral of FFTSR is
    signal a: std_logic;
begin
    process(clk, rst, set)
    begin
        if rst = '1' 
           then a <= '0';
        elsif set = '1'
           then a <= '1';
        elsif rising_edge(clk) 
           then if in_t = '1'
                then a <= not a;
                end if;
        end if;
    end process;
    out1 <= a;
end behavioral;

--------------------------
-- contatore delle parole da convertire
-- il contatore trasla di una posizone ad ogni fronte di discesa del clock
--------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity count_w is
    port(
        n_word: in std_logic_vector(7 downto 0);
        clk, start, rst: in std_logic; -- in segnale di start viene passato dal componente principale  
                           -- e viene assicurato che è dato coordinato ad un fronte di salita del clock
        go: in std_logic;  -- il segnale di go si deve alzare ad un fronte di discesa, così resetto 
                -- i segnali di stop a 0 e poi torna a 0 ad un fronte di salita, così al prossimo 
                -- fronte di discesa potrò aggiornare gli stop senza problemi 
                -- quando go è alto non posso ancora spostare il contatore delle parole in memoria
        stopped: out std_logic;
        out1: out std_logic_vector(7 downto 0);
        cached_n: out std_logic_vector(7 downto 0);
        ended: out std_logic
    );
end count_w;

architecture behavioral of count_w is
    component FFTSR is
        port(
            in_t: in std_logic;
            clk, set,rst: in std_logic;
            out1: out std_logic
        );
    end component;
    component FFT is
        port(
            in_t: in std_logic;
            clk, rst: in std_logic;
            out1: out std_logic
        );
    end component;
    component FlipFlop is
        port(
            in1: in std_logic;
            clk, rst: in std_logic;
            out1: out std_logic
        );
    end component;
    
    constant a: std_logic := '1';
    signal stop, stop_a, stop_b, stop_c: std_logic;
    signal first_read2: std_logic;
    -- uso 2 segnali first_read per salvare e iniziare a richiedere il numero di parole
    -- da leggere in memoria
    signal b0: std_logic;
    signal b1: std_logic;
    signal b2: std_logic;
    signal b3: std_logic;
    signal b4: std_logic;
    signal b5: std_logic;
    signal b6: std_logic;
    signal b7: std_logic;
begin
    -- flip flop per inizializzare first_read(1 e 2)
    ffd0: FlipFlop
        port map(a, start, rst or (clk and stop_a), first_read2);
    ffd1: FlipFlop
        port map(a, (not clk) and first_read2, rst or go, stop_a);
    
    ended <= stop_a and (not b0) and (not b1) and (not b2) and (not b3) and (not b4)
             and (not b5) and (not b6) and (not b7);
    -- flip flop che registrano uno spostamento dell'indice di mememoria da analizzare 
    -- e che stoppano i successivi spostamenti fino alla fine del calcolo del risultato
    -- da parte del convolutore
    fft0: FFT
        port map(a and (not first_read2), b0, rst or go, stop_b);
    fft1: FFT
        port map(a and (not first_read2), not b0, rst or go, stop_c);
    
    stop <= (not start) or stop_a or stop_b or stop_c or go;
    fftsr1: FFTSR
      port map(a, (not clk) and (not stop), first_read2 and n_word(0), 
               rst or (first_read2 and (not n_word(0))), b0);
    fftsr2: FFTSR
      port map(a, b0, first_read2 and n_word(1), 
               rst or (first_read2 and (not n_word(1))), b1);
    fftsr3: FFTSR
      port map(a, b1, first_read2 and n_word(2), 
               rst or (first_read2 and (not n_word(2))), b2);
    fftsr4: FFTSR
      port map(a, b2, first_read2 and n_word(3), 
               rst or (first_read2 and (not n_word(3))), b3);
    fftsr5: FFTSR
      port map(a, b3, first_read2 and n_word(4), 
               rst or (first_read2 and (not n_word(4))), b4);
    fftsr6: FFTSR
      port map(a, b4, first_read2 and n_word(5), 
               rst or (first_read2 and (not n_word(5))), b5);
    fftsr7: FFTSR
      port map(a, b5, first_read2 and n_word(6), 
               rst or (first_read2 and (not n_word(6))), b6);
    fftsr8: FFTSR
      port map(a, b6, first_read2 and n_word(7), 
               rst or (first_read2 and (not n_word(7))), b7);
    
    -- se start è 0 dico agli altri che non sono stoppato anche se in realtà lo sono 
    -- così tutto il circuito rimane fermo (come è giusto che sia per start=0)
    stopped <= stop and start;
    out1(0) <= b0;
    out1(1) <= b1;
    out1(2) <= b2;
    out1(3) <= b3;
    out1(4) <= b4;
    out1(5) <= b5;
    out1(6) <= b6;
    out1(7) <= b7;
    
    -- memoria che ricorda il numero di parole salvate in posizione 0
    mem0: FlipFlop 
      port map(n_word(0), first_read2, rst, cached_n(0));
    mem1: FlipFlop 
      port map(n_word(1), first_read2, rst, cached_n(1));
    mem2: FlipFlop 
      port map(n_word(2), first_read2, rst, cached_n(2));
    mem3: FlipFlop 
      port map(n_word(3), first_read2, rst, cached_n(3));
    mem4: FlipFlop 
      port map(n_word(4), first_read2, rst, cached_n(4));
    mem5: FlipFlop 
      port map(n_word(5), first_read2, rst, cached_n(5));
    mem6: FlipFlop 
      port map(n_word(6), first_read2, rst, cached_n(6));
    mem7: FlipFlop 
      port map(n_word(7), first_read2, rst, cached_n(7));
end behavioral;

--------------------------
-- input code of multiplexer
--------------------------

library ieee;
use ieee.std_logic_1164.all;

entity code is
   port(
        clk: in std_logic;
        stopped: in std_logic;
        out1 : out std_logic_vector(2 downto 0)
   );
end code;

architecture behavioral of code is
    component FFT is
        port(
            in_t: in std_logic;
            clk, rst: in std_logic;
            out1: out std_logic
        );
    end component; 
    
    constant a: std_logic := '1';
    signal b0: std_logic;
    signal b1: std_logic;
    signal b2: std_logic;
begin
    fft1: FFT
      port map(a, clk, not stopped, b0);
    fft2: FFT
      port map(a, b0, not stopped, b1);
    fft3: FFT
      port map(a, b1, not stopped, b2);
    out1(0) <= b0;
    out1(1) <= b1;
    out1(2) <= b2;
end behavioral;

--------------------------
-- multiplexer
--------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mutex is 
    port(
        in1: in std_logic_vector(7 downto 0);
        clk: in std_logic;
        stopped: in std_logic;
        current_bit: out std_logic_vector(2 downto 0);
        out1 : out std_logic
    );
end mutex;


architecture behavioral of mutex is
    component code is
       port(
            clk: in std_logic;
            stopped: in std_logic;
            out1 : out std_logic_vector(2 downto 0)
       );
    end component;
    
    signal ctrl: std_logic_vector(2 downto 0);
begin
    cd: code
      port map(clk, stopped, ctrl);
    
    current_bit <= ctrl;
    
    with ctrl select 
      out1 <= in1(0) when "000",
              in1(1) when "001",
              in1(2) when "010",
              in1(3) when "011",
              in1(4) when "100",
              in1(5) when "101",
              in1(6) when "110",
              in1(7) when others;
end behavioral;

--------------------------
-- Convolutore
--------------------------

library ieee;
use ieee.STD_LOGIC_1164.ALL;

entity Convolutore is
    port(
        clk: in std_logic;
        rst: in std_logic;
        i_data: in std_logic;
        out1: out std_logic;
        out2: out std_logic
        );
end Convolutore;

architecture behavioral of Convolutore is
    signal tmp0: std_logic;
    signal tmp1: std_logic;
    signal tmp2: std_logic;
    component FlipFlop is
        port( in1: in std_logic;
              clk, rst: in std_logic;
              out1: out std_logic
        );
    end component; 
begin
    ffd0: FlipFlop 
      port map(i_data, clk, rst, tmp0);
    ffd1: FlipFlop 
      port map(tmp0, clk, rst, tmp1);
    ffd2: FlipFlop 
      port map(tmp1, clk, rst, tmp2);
    
    out1 <= tmp0 xor tmp2;
    out2 <= tmp0 xor tmp1 xor tmp2;
end behavioral;

----------------------------------------------------------------------------------
-- NB: devo pottare i bit dal più significativo al meno sign., inoltre
-- dopo aver calcolato le 2 uscite pk1 va al bit più significativo e 
-- pk2 al meno significativo (partendo dalla cima più sign. del byte)
-- quindi il primissimo bit servirà a calcolare i 2 bit più sign. del 
-- byte che in memoria andrà alla posizione 1000  
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity calcolatore is
    port(
        in1: in std_logic_vector(7 downto 0);
        clk, rst: in std_logic;
        stopped: in std_logic;
        en_w: out std_logic;
        word1or2: out std_logic;
        go: out std_logic;
        out_byte: out std_logic_vector(7 downto 0)
    );
end calcolatore;

architecture behavioral of calcolatore is
    component FFT is
        port(
            in_t: in std_logic;
            clk, rst: in std_logic;
            out1: out std_logic
        );
    end component;
    component FlipFlop is
        port( in1: in std_logic;
              clk, rst: in std_logic;
              out1: out std_logic
        );
    end component;
    component Latch is
        port(
            in1: in std_logic;
            clk, rst: in std_logic;
            out1: out std_logic
        );
    end component;
    component Convolutore is
        port(
            clk: in std_logic;
            rst: in std_logic;
            i_data: in std_logic;
            out1: out std_logic;
            out2: out std_logic
        );
    end component;
    component mutex is 
        port(
            in1: in std_logic_vector(7 downto 0);
            clk: in std_logic;
            stopped: in std_logic;
            current_bit: out std_logic_vector(2 downto 0);
            out1 : out std_logic
        );
    end component;
    
    signal curr_b: std_logic_vector(2 downto 0);
    signal bit1: std_logic;
    signal bits: std_logic_vector(1 downto 0);
    signal pause: std_logic;
    signal pause1, pause2, pause3: std_logic;
    signal go1: std_logic;
    signal en_w1: std_logic;
    signal write_cases: std_logic;
begin
    mutx: mutex
      port map(in1, clk and (not en_w1), stopped, curr_b, bit1);
    conv: Convolutore
      port map((not clk) and pause, rst, bit1, bits(1), bits(0));
    
    -- pausa del convolutore per permettere al primo bit in ingresso di settarsi 
    -- da quando stopped di count_w è stato settato a 1
    -- pause = 0 fermo il convolutore, pause = 1 via libera
    ffd0: FlipFlop
      port map(stopped , clk, not stopped, pause1);
    -- flip flop addetto a stoppare il circuito alla fine del calcolo del convolutore, 
    -- quando go diventa 1 e stopped sta per essere riportato a 0
    ffd1: FlipFlop
      port map('1' , go1 or rst, pause1, pause3);
    
    write_cases <= (not curr_b(0)) and (not curr_b(1));
    
    -- flip flop che predispone la memoria ad essere scritta (quando il contatore è a 4 
    -- e quando il contatore è a 0, ma non la prima volta quando pause1 è ancora=0)
    fft0: FFT
      port map(write_cases and pause1, not clk, (not stopped) or rst, en_w1);
    en_w <= en_w1;
    
    ffd2: FlipFlop
      port map(en_w1 , clk, rst, pause2);
    
    pause <= pause1 and (not pause2) and (not pause3);
    
    -- flip flop che setta il segnale di go
    ffd3: FlipFlop
      port map(write_cases and pause1 and (not curr_b(2)), not en_w1, clk or rst, go1);
    go <= go1;
    
    word1or2 <= curr_b(2);
    -- primo bit della memoria temporanea che andrà caricata in memoria, va settato solo 
    -- quando c'è un fronte di salita e il curr_b = "000" oppure "100"
    mem0: Latch 
      port map(bits(0), (not clk) and (not curr_b(1)) and (not curr_b(0)), rst, out_byte(0));
    mem1: Latch 
      port map(bits(1), (not clk) and (not curr_b(1)) and (not curr_b(0)), rst, out_byte(1));
    mem2: Latch 
      port map(bits(0), (not clk) and (not curr_b(1)) and curr_b(0), rst, out_byte(2));
    mem3: Latch 
      port map(bits(1), (not clk) and (not curr_b(1)) and curr_b(0), rst, out_byte(3));
    mem4: Latch 
      port map(bits(0), (not clk) and curr_b(1) and (not curr_b(0)), rst, out_byte(4));
    mem5: Latch 
      port map(bits(1), (not clk) and curr_b(1) and (not curr_b(0)), rst, out_byte(5));
    mem6: Latch 
      port map(bits(0), (not clk) and curr_b(1) and curr_b(0), rst, out_byte(6));
    mem7: Latch 
      port map(bits(1), (not clk) and curr_b(1) and curr_b(0), rst, out_byte(7));
end behavioral;

---------------------------------
---------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    component calcolatore is
        port(
            in1: in std_logic_vector(7 downto 0);
            clk, rst: in std_logic;
            stopped: in std_logic;
            en_w: out std_logic;
            word1or2: out std_logic;
            go: out std_logic;
            out_byte: out std_logic_vector(7 downto 0)
        );
    end component;
    component count_w is
        port(
            n_word: in std_logic_vector(7 downto 0);
            clk, start, rst: in std_logic; -- in segnale di start viene passato dal componente principale  
                               -- e viene assicurato che è dato coordinato ad un fronte di salita del clock
            go: in std_logic;  -- il segnale di go si deve alzare ad un fronte di discesa, così resetto 
                    -- i segnali di stop a 0 e poi torna a 0 ad un fronte di salita, così al prossimo 
                    -- fronte di discesa potrò aggiornare gli stop senza problemi 
                    -- quando go è alto non posso ancora spostare il contatore delle parole in memoria
            stopped: out std_logic;
            out1: out std_logic_vector(7 downto 0);
            cached_n: out std_logic_vector(7 downto 0);
            ended: out std_logic
        );
    end component;
    component FlipFlop is
        port(
            in1: in std_logic;
            clk, rst: in std_logic;
            out1: out std_logic
        );
    end component;
    component FFT is
        port(
            in_t: in std_logic;
            clk, rst: in std_logic;
            out1: out std_logic
        );
    end component;
    
    signal pos, pos2: std_logic_vector(7 downto 0);
    signal pos1: std_logic_vector(15 downto 0);
    signal go: std_logic;
    signal stopped: std_logic;
    signal start: std_logic;
    signal en_w: std_logic;
    signal word1or2: std_logic;
    signal flagSt0, flagSt1: std_logic;
    signal sel: std_logic_vector(1 downto 0);
    signal done, done0, done1: std_logic;
    signal clk: std_logic;
    signal cachedN: std_logic_vector(7 downto 0);
    signal ended: std_logic;
begin
    contatore_i: count_w 
      port map(i_data, clk, start, flagSt1, go, stopped, pos, cachedN, ended);
    elaboratore: calcolatore
      port map(i_data, clk and (not ended), flagSt1, stopped, en_w, word1or2, go, o_data);
    
    o_we <= en_w;
    -- segnali usati per settare start: flagSt0 è a 1 dal primo fronte di salita
    -- in cui start=1 al terzo fronte di salita, non viene riportato a 0 dal 
    -- secondo poichè flagSt1 lo blocca (andando ad 1 sul primo fronte di discesa 
    -- del clk da quando flagSt0 è =1, al secondo);
    -- mentre start va a 1 quando flagSt0 scende a 0
    -- posso quindi usare flagSt1 come rst 
    setStart0: FFT
      port map(i_start and (not start), clk and (not flagSt1), 
                (not i_start) or i_rst, flagSt0);
    setStart1: FFT
      port map(flagSt0, not clk, (not i_start) or i_rst, flagSt1);
    setStart2: FlipFlop
      port map('1', not flagSt0, (not i_start) or i_rst, start);
    
    sel <= en_w & word1or2;
    with pos select
        pos2 <= pos when "00000000",
                std_logic_vector(signed(cachedN) - signed(pos) + 1) when others;
    pos1 <= "00000000" & pos2;
    with sel select
        o_address <= std_logic_vector(signed(pos1)+signed(pos1)+998) when "11",
                     std_logic_vector(signed(pos1)+signed(pos1)+999) when "10",
                     "00000000" & pos2 when others;
    
    -- alzo done quando pos='00000001' e lo abbasso con reset quando start=0
    ffDone0: FlipFlop
      port map(start and (not pos(7)) and (not pos(6)) and (not pos(5)) and (not pos(4))
               and (not pos(3)) and (not pos(2)) and (not pos(1)) and pos(0),
               go, not start, done0);
    ffDone1: FlipFlop
      port map('1', ended, not start, done1);
    done <= done0 or done1;
    o_done <= done;
    o_en <= (not done) and i_start;
    clk <= i_clk or done;
end behavioral;
