`include "openMSP430_defines.v"
module omsp430_demo_top
(
    input   wire            I_CLK,
    input   wire            I_RESET_N,

    output  wire            O_DEBUG_FREEZE,
    output  wire            O_DEBUG_TXD,
    input   wire            I_DEBUG_RXD,
    output  wire            O_PLL_LOCKED,

    output  wire            O_UART_TXD,
    input   wire            I_UART_RXD,

    inout   wire    [7:0]   B_PORT0,
    inout   wire    [7:0]   B_PORT1,

    input   wire            I_IRQ0_N,
    input   wire            I_IRQ1_N,

    inout   wire            B_I2C_SCL,
    inout   wire            B_I2C_SDA

);

    wire                    clk;
    wire                    cpu_clk;
    wire                    reset;

    wire    [`PMEM_MSB:0]   pmem_addr;
    wire    [15:0]          pmem_data;
    wire    [15:0]          pmem_q;
    wire                    pmem_cen;
    wire    [1:0]           pmem_wen;

    wire    [`DMEM_MSB:0]   dmem_addr;
    wire    [15:0]          dmem_data;
    wire    [15:0]          dmem_q;
    wire                    dmem_cen;
    wire    [1:0]           dmem_wen;

    wire                    puc_rst;
    wire                    per_clk;
    wire    [13:0]          per_addr;
    wire    [15:0]          per_mosi;
    wire    [15:0]          per_miso;
    wire    [15:0]          per_miso_uart;
    wire    [15:0]          per_miso_i2c;
    wire    [15:0]          per_miso_gpio;
    wire                    per_en;
    wire    [1:0]           per_we;

    wire    [13:0]          irq_bus;
    wire                    irq_irq0;
    wire                    irq_irq1;

    wire                    uart_rxclear;
    wire    [7:0]           uart_rxdata;
    wire                    uart_rxerr;
    wire                    uart_rxdone;
    wire                    uart_txrun;
    wire    [7:0]           uart_txdata;
    wire                    uart_txdone;
    wire    [15:0]          uart_prer;

    wire    [15:0]          i2c_prer;
    wire                    i2c_core_en;
    wire    [7:0]           i2c_txd;
    wire                    i2c_sta;
    wire                    i2c_sto;
    wire                    i2c_rd;
    wire                    i2c_wr;
    wire                    i2c_ack;
    wire    [7:0]           i2c_rxd;
    wire                    i2c_busy;
    wire                    i2c_al;
    wire                    i2c_irxack;
    wire                    i2c_done;
    wire                    i2c_scl_o;
    wire                    i2c_sda_o;
    wire                    i2c_scl_oe_n;
    wire                    i2c_sda_oe_n;

    wire    [7:0]           gpio_port0_dir;
    wire    [7:0]           gpio_port0_out;
    wire    [7:0]           gpio_port1_dir;
    wire    [7:0]           gpio_port1_out;

    assign clk = I_CLK;
    assign reset = ~I_RESET_N;
    assign irq_irq0 = ~I_IRQ0_N;
    assign irq_irq1 = ~I_IRQ1_N;

    //-------------------------------------------------------------------------
    //  PLL
    //-------------------------------------------------------------------------
    media_pll m_mediapll0
    (
        .refclk     (clk),          // 50MHz
        .rst        (reset),        // Async reset
        .outclk_0   (cpu_clk),      // 25MHz
        .locked     (O_PLL_LOCKED)
	);


    //-------------------------------------------------------------------------
    //  Controller core
    //-------------------------------------------------------------------------
    // Program memory ---------------------------------------------------------
    progmem m_progmem0
    (
        .address    (pmem_addr),
        .byteena    (~pmem_wen[1:0]),
        .clken      (~pmem_cen),
        .clock      (cpu_clk),
        .data       (pmem_data[15:0]),
        .wren       (~(&pmem_wen[1:0])),
        .q          (pmem_q[15:0])
    );

    // Data memory ------------------------------------------------------------
    datamem m_datamem0
    (
        .address    (dmem_addr),
        .byteena    (~dmem_wen[1:0]),
        .clken      (~dmem_cen),
        .clock      (cpu_clk),
        .data       (dmem_data[15:0]),
        .wren       (~(&dmem_wen[1:0])),
        .q          (dmem_q[15:0])
    );

    // CPU --------------------------------------------------------------------
    openMSP430 m_cpu0
    (
        // output
        .aclk               (),                     // ASIC ONLY: ACLK
        .aclk_en            (),                     // FPGA ONLY: ACLK enable
        .dbg_freeze         (O_DEBUG_FREEZE),       // Freeze peripherals
        .dbg_i2c_sda_out    (),                     // Debug interface: I2C SDA OUT
        .dbg_uart_txd       (O_DEBUG_TXD),          // Debug interface: UART TXD
        .dco_enable         (),                     // ASIC ONLY: Fast oscillator enable
        .dco_wkup           (),                     // ASIC ONLY: Fast oscillator wake-up (asynchronous)
        .dmem_addr          (dmem_addr),            // Data Memory address
        .dmem_cen           (dmem_cen),             // Data Memory chip enable (low active)
        .dmem_din           (dmem_data),            // Data Memory data input
        .dmem_wen           (dmem_wen),             // Data Memory write byte enable (low active)
        .irq_acc            (),                     // Interrupt request accepted (one-hot signal)
        .lfxt_enable        (),                     // ASIC ONLY: Low frequency oscillator enable
        .lfxt_wkup          (),                     // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
        .mclk               (per_clk),              // Main system clock
        .dma_dout           (),                     // Direct Memory Access data output
        .dma_ready          (),                     // Direct Memory Access is complete
        .dma_resp           (),                     // Direct Memory Access response (0:Okay / 1:Error)
        .per_addr           (per_addr),             // Peripheral address
        .per_din            (per_mosi),             // Peripheral data input
        .per_en             (per_en),               // Peripheral enable (high active)
        .per_we             (per_we),               // Peripheral write byte enable (high active)
        .pmem_addr          (pmem_addr),            // Program Memory address
        .pmem_cen           (pmem_cen),             // Program Memory chip enable (low active)
        .pmem_din           (pmem_data),            // Program Memory data input (optional)
        .pmem_wen           (pmem_wen),             // Program Memory write enable (low active) (optional)
        .puc_rst            (puc_rst),              // Main system reset
        .smclk              (),                     // ASIC ONLY: SMCLK
        .smclk_en           (),                     // FPGA ONLY: SMCLK enable

        //input
        .cpu_en             (1'b1),                 // Enable CPU code execution (asynchronous and non-glitchy)
        .dbg_en             (1'b1),                 // Debug interface enable (asynchronous and non-glitchy)
        .dbg_i2c_addr       (7'h00),                // Debug interface: I2C Address
        .dbg_i2c_broadcast  (7'h00),                // Debug interface: I2C Broadcast Address (for multicore systems)
        .dbg_i2c_scl        (1'b1),                 // Debug interface: I2C SCL
        .dbg_i2c_sda_in     (1'b1),                 // Debug interface: I2C SDA IN
        .dbg_uart_rxd       (I_DEBUG_RXD),          // Debug interface: UART RXD (asynchronous)
        .dco_clk            (cpu_clk),              // Fast oscillator (fast clock)
        .dmem_dout          (dmem_q),               // Data Memory data output
        .irq                (irq_bus),              // Maskable interrupts (14, 30 or 62)
        .lfxt_clk           (1'b0),                 // Low frequency oscillator (typ 32kHz)
        .dma_addr           (15'h0000),             // Direct Memory Access address
        .dma_din            (16'h0000),             // Direct Memory Access data input
        .dma_en             (1'b0),                 // Direct Memory Access enable (high active)
        .dma_priority       (1'b0),                 // Direct Memory Access priority (0:low / 1:high)
        .dma_we             (2'b00),                // Direct Memory Access write byte enable (high active)
        .dma_wkup           (1'b0),                 // ASIC ONLY: DMA Wake-up (asynchronous and non-glitchy)
        .nmi                (1'b0),                 // Non-maskable interrupt (asynchronous and non-glitchy)
        .per_dout           (per_miso),             // Peripheral data output
        .pmem_dout          (pmem_q),               // Program Memory data output
        .reset_n            (I_RESET_N),            // Reset Pin (active low, asynchronous and non-glitchy)
        .scan_enable        (1'b0),                 // ASIC ONLY: Scan enable (active during scan shifting)
        .scan_mode          (1'b0),                 // ASIC ONLY: Scan mode
        .wkup               (1'b0)                  // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
    );

    // Peripheral data bus (Master-In Slave-Out) ------------------------------
    assign per_miso = per_miso_uart | per_miso_i2c | per_miso_gpio;

    // Interrupt request bus --------------------------------------------------
    //  If the same interrupt is received during interrupt processing, 
    //  the CPU may run out of control due to multiple interrupts.
    //  This is not a phenomenon unique to openMSP430, as the same thing happens 
    //  in many microcontrollers.
    //  To avoid runaway, it is necessary to prevent multiple interrupts by some means.
    assign irq_bus   = {
                            1'b0,       // Vector 13  (0xFFFA)
                            1'b0,       // Vector 12  (0xFFF8)
                            1'b0,       // Vector 11  (0xFFF6)
                            1'b0,       // Vector 10  (0xFFF4) - Watchdog -
                            1'b0,       // Vector  9  (0xFFF2)
                            1'b0,       // Vector  8  (0xFFF0)
                            1'b0,       // Vector  7  (0xFFEE)
                            1'b0,       // Vector  6  (0xFFEC)
                            1'b0,       // Vector  5  (0xFFEA)
                            1'b0,       // Vector  4  (0xFFE8)
                            1'b0,       // Vector  3  (0xFFE6)
                            1'b0,       // Vector  2  (0xFFE4)
                            irq_irq1,   // Vector  1  (0xFFE2)
                            irq_irq0    // Vector  0  (0xFFE0)
    };


    //-------------------------------------------------------------------------
    //  Peripheral module registers
    //-------------------------------------------------------------------------
    // Basic UART Register ----------------------------------------------------
    regs_uart m_regs_uart0
    (
        .i_mclk             (per_clk),
        .i_per_addr         (per_addr),
        .i_per_din          (per_mosi),
        .i_per_en           (per_en),
        .i_per_we           (per_we),
        .i_puc_rst          (puc_rst),
        .o_per_dout         (per_miso_uart),
        .o_rxclear          (uart_rxclear),
        .i_rxdata           (uart_rxdata),
        .i_rxerr            (uart_rxerr),
        .i_rxdone           (uart_rxdone),
        .o_txrun            (uart_txrun),
        .o_txdata           (uart_txdata),
        .i_txdone           (uart_txdone),
        .o_prer             (uart_prer)
    );

    // I2C master Register ----------------------------------------------------
    regs_i2c m_regs_i2c0
    (
        .i_mclk         (per_clk),
        .i_per_addr     (per_addr),
        .i_per_din      (per_mosi),
        .i_per_en       (per_en),
        .i_per_we       (per_we),
        .i_puc_rst      (puc_rst),
        .o_per_dout     (per_miso_i2c),
        .o_prer         (i2c_prer),
        .o_core_en      (i2c_core_en),
        .o_txd          (i2c_txd),
        .o_sta          (i2c_sta),
        .o_sto          (i2c_sto),
        .o_rd           (i2c_rd),
        .o_wr           (i2c_wr),
        .o_ack          (i2c_ack),
        .i_rxd          (i2c_rxd),
        .i_busy         (i2c_busy),
        .i_al           (i2c_al),
        .i_irxack       (i2c_irxack),
        .i_done         (i2c_done)
    );

    // Basic GPIO Register ----------------------------------------------------
    regs_gpio m_regs_gpio0
    (
        .o_per_dout     (per_miso_gpio),
        .o_dir0         (gpio_port0_dir),   // GPIO0 direction (0=input, 1=output)
        .o_dout0        (gpio_port0_out),
        .o_dir1         (gpio_port1_dir),   // GPIO1 direction (0=input, 1=output)
        .o_dout1        (gpio_port1_out),
        .i_mclk         (per_clk),
        .i_per_addr     (per_addr),
        .i_per_din      (per_mosi),
        .i_per_en       (per_en),
        .i_per_we       (per_we),
        .i_puc_rst      (puc_rst),
        .i_din0         (B_PORT0),
        .i_din1         (B_PORT1)
    );


    //-------------------------------------------------------------------------
    //  Basic UART
    //-------------------------------------------------------------------------
    uart_tmct_top m_uart0
    (
        .i_clk              (per_clk),
        .i_reset            (reset),
        .i_rxclear          (uart_rxclear),
        .o_rxdata           (uart_rxdata),
        .o_rxerr            (uart_rxerr),
        .o_rxdone           (uart_rxdone),
        .i_txrun            (uart_txrun),
        .i_txdata           (uart_txdata),
        .o_txdone           (uart_txdone),
        .i_prer             (uart_prer),
        .i_rx               (I_UART_RXD),
        .o_tx               (O_UART_TXD),
        .o_debug_rxclken    (),
        .o_debug_txclken    ()

    );


    //-------------------------------------------------------------------------
    //  Basic GPIO
    //-------------------------------------------------------------------------
    assign B_PORT0[7] = gpio_port0_dir[7] ? gpio_port0_out[7] : 1'bz;
    assign B_PORT0[6] = gpio_port0_dir[6] ? gpio_port0_out[6] : 1'bz;
    assign B_PORT0[5] = gpio_port0_dir[5] ? gpio_port0_out[5] : 1'bz;
    assign B_PORT0[4] = gpio_port0_dir[4] ? gpio_port0_out[4] : 1'bz;
    assign B_PORT0[3] = gpio_port0_dir[3] ? gpio_port0_out[3] : 1'bz;
    assign B_PORT0[2] = gpio_port0_dir[2] ? gpio_port0_out[2] : 1'bz;
    assign B_PORT0[1] = gpio_port0_dir[1] ? gpio_port0_out[1] : 1'bz;
    assign B_PORT0[0] = gpio_port0_dir[0] ? gpio_port0_out[0] : 1'bz;
    assign B_PORT1[7] = gpio_port1_dir[7] ? gpio_port1_out[7] : 1'bz;
    assign B_PORT1[6] = gpio_port1_dir[6] ? gpio_port1_out[6] : 1'bz;
    assign B_PORT1[5] = gpio_port1_dir[5] ? gpio_port1_out[5] : 1'bz;
    assign B_PORT1[4] = gpio_port1_dir[4] ? gpio_port1_out[4] : 1'bz;
    assign B_PORT1[3] = gpio_port1_dir[3] ? gpio_port1_out[3] : 1'bz;
    assign B_PORT1[2] = gpio_port1_dir[2] ? gpio_port1_out[2] : 1'bz;
    assign B_PORT1[1] = gpio_port1_dir[1] ? gpio_port1_out[1] : 1'bz;
    assign B_PORT1[0] = gpio_port1_dir[0] ? gpio_port1_out[0] : 1'bz;


    //-------------------------------------------------------------------------
    //  I2C Master
    //-------------------------------------------------------------------------
    assign B_I2C_SCL = i2c_scl_oe_n ? 1'bz : i2c_scl_o; 
    assign B_I2C_SDA = i2c_sda_oe_n ? 1'bz : i2c_sda_o; 
	
    i2c_master_byte_ctrl m_i2c_master0
    (
        .clk        (per_clk),
        .rst        (reset),
        .nReset     (I_RESET_N),
        .ena        (i2c_core_en),
        .clk_cnt    (i2c_prer),
        .start      (i2c_sta),
        .stop       (i2c_sto),
        .read       (i2c_rd),
        .write      (i2c_wr),
        .ack_in     (i2c_ack),
        .din        (i2c_txd),
        .cmd_ack    (i2c_done),
        .ack_out    (i2c_irxack),
        .dout       (i2c_rxd),
        .i2c_busy   (i2c_busy),
        .i2c_al     (i2c_al),
        .scl_i      (B_I2C_SCL),
        .scl_o      (i2c_scl_o),
        .scl_oen    (i2c_scl_oe_n),
        .sda_i      (B_I2C_SDA),
        .sda_o      (i2c_sda_o),
        .sda_oen    (i2c_sda_oe_n)
	);

endmodule
