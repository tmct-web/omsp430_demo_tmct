# Specification: Basic UART module
The Basic UART module provides very basic UART transmit/receive functionality.
Supported communication specifications are as follows:

Basic UARTモジュールはごく基本的なUART送受信機能を提供します。  
サポートする通信仕様は以下の通りです:

| Item | Value |
| :-- | :-- |
| Start bits | 1 bit |
| Data bits | 8 bit |
| Stop bits | 1 bit |
| Parity bit | None |
| Flow control | None |


## Register map
The register map is shown below.

レジスタマップを以下に示します。

| Address | Reg. name |
| :-- | :-- |
| 0x00a0 | UART_CNTRL  |
| 0x00a1 | UART_PRERH  |
| 0x00a2 | UART_PRERL  |
| 0x00a3 | UART_RXDATA |
| 0x00a4 | UART_TXDATA |


### 〔0x00a0〕 UART_CNTRL Register
The UART_CNTRL register can control the start/stop of the transmit/receive operation of this module and the clearing of error flags.

UART_CNTRL レジスタはこのモジュールの送受信動作の動作開始・停止 および エラーフラグの消去を制御することができます。

| Bit | R/W | Bit name | Default | Details |
| :-- | :-- | :-- | :-- | :-- |
| 7  | R/W | TXRUN | 0 | Transmission operation starts at the timing set from '0' to '1'.<br/>'0'→'1'に設定したタイミングで送信動作を開始します。 |
| 6  | R   | - | 0 | Not assigned. |
| 5  | R   | - | 0 | Not assigned. |
| 4  | R   | TXDONE | - | Indicates the status of the transmission operation.<br/>送信動作の状態を示します。<br/>'1' = Transmission complete  送信完了<br/>'0' = Transmission in progress or stopped  送信中または停止中 |
| 3  | R/W | RXCLEAR | 0 | Sets the receive operation.<br/>受信動作を設定します。<br/>'1' = Stop receiving and clear various receiving flags  受信停止・各種フラグクリア<br/>'0' = Allow receive operation  受信動作許可 |
| 2  | R   | - | 0 | Not assigned. |
| 1  | R   | RXERR | - | Indicates the status of receiving errors.<br/>受信エラーの発生状況を示します。<br/>'1' = Receiving error  受信エラー<br/>'0' = No error  エラーなし |
| 0  | R   | RXDONE | - | Indicates the status of the receiving operation.<br/>受信動作の状態を示します。<br/>'1' = Receiving completed  受信完了<br/>'0' = Waiting for reception or stopped  受信待ちまたは停止中 |


### 〔0x00a1〕 UART_PRERH Register
This register is used to set the transmit/receive baud rate. See UART_PRERL register for details.

送受信ボーレート設定・取得用のレジスタです。詳細は UART_PRERL レジスタを参照してください。


### 〔0x00a2〕 UART_PRERL Register
This register is used to set/get the transmit/receive baud rate. The UART_PRERH register is the upper 8 bits and this register is the lower 8 bits, for a total of 16 bits.  
The setting value of this register can be calculated by dividing the operating frequency (Hz) supplied to the module by the baud rate (bps).  
For example, if 9600bps is desired at i_clk=50MHz, 50,000,000 ÷ 9600 = 5208(dec) = 0x1458(hex); therefore, set UART_PRERH = 0x14; UART_PRERL = 0x58.

送受信ボーレート設定・取得用のレジスタです。 UART_PRERH レジスタが上位8ビット、このレジスタが下位8ビットの合計16ビットです。  
このモジュールに供給される動作周波数(Hz) を ボーレード(bps) で割った値を設定します。  
たとえば i_clk=50MHz で 9600bps に設定したい場合、 50,000,000 ÷ 9600 = 5208(dec) = 0x1458(hex) となるため UART_PRERH = 0x14; UART_PRERL = 0x58 とします。


### 〔0x00a3〕 UART_RXDATA Register
The data received from the UART is stored. Only Read is valid and Write is not available.  
Valid when RXDONE = '1' and RXERR = '0' in the UART_CNTRL register. Otherwise, an invalid value is read.

UARTからの受信データが格納されます。Read のみ有効で Write はできません。  
UART_CNTRLレジスタの RXDONE ='1' かつ RXERR = '0' のとき有効です。それ以外では不定値が読み出されます。


### 〔0x00a4〕 UART_TXDATA Register
Stores data to be sent to the UART, both Read and Write are possible.  
After TXRUN = '0' to '1' in the UART_CNTRL register, the same value must be held until TXDONE = '1' is read. (If a Write is performed during this time, an invalid value may be sent.)

UARTへ送信したいデータを格納します。Read/Write とも可能です。  
UART_CNTRLレジスタの TXRUN = '0'→'1' にした後、TXDONE = '1' が読み出されるまでは同一値を保持する必要があります。(この間に Write した場合、不定値が送信される可能性があります。)


## How to use this module
The control and use of this module is shown below.

このモジュールの制御方法・使用方法を以下に示します。


### Initialization
This module must be initialized before use.  
Follow the procedure below to initialize. Upon completion of initialization, this module is ready for transmission and reception.

このモジュールは使用前に初期化が必要です。  
以下の手順で初期化します。初期化が完了次第、本モジュールは送受信完了な状態になります。

1. Set UART_PRERH and UART_PRERL to values corresponding to the baud rate.  
  UART_PRERH, UART_PRERL にボーレートに対応する値を設定します。
1. Wait for 1 byte period at the set baud rate.  
  設定したボーレートでの1バイト期間分ウェイトします。


### Receive operation
The following procedure is used to receive the data.  
Repeat this procedure if you wish to receive multiple bytes of data.

受信は以下の手順で行います。  
複数のバイトデータを受信したい場合はこの手順を繰り返します。  

1. After setting UART_CNTRL:RXCLEAR = '1', set it to '0' to start receive operation.  
  UART_CNTRL:RXCLEAR = '1' にした後、'0' にして受信動作を開始します。
1. Wait until UART_CNTRL:RXDONE = '1' (=receive complete).  
  UART_CNTRL:RXDONE = '1' になるまで(=受信完了まで)待ちます。
1. If UART_CNTRL:RXERR = '0', the received data is retrieved from the UART_RXDATA register.  
  If UART_CNTRL:RXERR = '1', the reception has failed and the procedure from 1. is repeated to try to receive again.  
  UART_CNTRL:RXERR = '0' であれば UART_RXDATA レジスタから受信されたデータを取得します。  
  UART_CNTRL:RXERR = '1' の場合、受信に失敗しているので 1. からの手順を再度行って再受信を試みます。

> Since this module supports only basic unbuffered functions, data cannot be received between the completion of reception and the start of the next reception.  
> If data is sent continuously at short intervals, the possibility of data being missed increases.  
> このモジュールはバッファのない基本的な機能しかサポートしていないため、受信完了〜次の受信開始までの間はデータを受信することができません。  
> 短い間隔で連続してデータが送信されてくる場合、データの取りこぼしが発生する可能性が高まります。


### Transmission operation
The following procedure is used to send the data.  
To send multiple bytes of data, repeat this operation.

送信は以下の手順で行います。  
複数のバイトデータを送信する場合はこの操作を繰り返します。

1. UART_CNTRL:TXRUN = set to '0' if not '0'.  
  UART_CNTRL:TXRUN = '0' でない場合は '0' に設定します。
1. Set the data you want to send to UART_TXDATA.  
  UART_TXDATA に送信したいデータをセットします。
1. Set UART_CNTRL:TXRUN = '1'.  
  UART_CNTRL:TXRUN = '1' とします。
1. Wait until UART_CNTRL:TXDONE = '1'.  
  UART_CNTRL:TXDONE = '1' となるまで待ちます。

