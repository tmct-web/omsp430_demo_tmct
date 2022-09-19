# basic_uart_tmct
This is a UART transmitter/receiver module that implements only very basic functions.  
It is written in System Verilog and operates correctly on the actual FPGA.  
The structure is easy to understand because it omits features such as double buffering, making it ideal as a subject for learning the basics of ser-des(Serializer/Deserializer).  
Supported communication specifications are as follows:

| Item | Value |
| :-- | :-- |
| Start bits | 1 bit |
| Data bits | 8 bit |
| Stop bits | 1 bit |
| Parity bit | None |
| Flow control | None |

Please note that this module is distributed under the 3-article BSD license. You are free to use it as long as you do not violate the terms of use.

ごく基本的な機能のみを実装したUART送受信モジュールです。System Verilogで記述されており、実際のFPGA上でも正常に動作することを確認済みです。  
ダブルバッファリングなどの機能を省いている分、理解しやすい構成になっていますので ser-des(シリアライザ/デシリアライザ) の基礎を学ぶための題材にも最適です。  
サポートする通信仕様は以下の通りです:

| Item | Value |
| :-- | :-- |
| Start bits | 1 bit |
| Data bits | 8 bit |
| Stop bits | 1 bit |
| Parity bit | None |
| Flow control | None |

なお、本モジュールは3条項BSDライセンスのもとに配布されます。利用条項に違反しない限り自由にご利用ください。  
※日本語の解説文は英語の解説文の下にあります。

---

## File Organization
basic_uart_tmct is composed of the following four files.  
The file names and the role of each file are shown below.

| File name | Details |
| :-- | :-- |
| uart_tmct_top.sv | Top-level file of this module. |
| uart_brgene.sv | The baud rate generator.<br/>Generates transmit/receive timing signals according to the set baud rate. |
| uart_rx.sv | Receiving operation and its sequence control. |
| uart_tx.sv | Transmission operation and its sequence control. |


## Input/Output Signals
Details on the signals input and output for uart_tmct_top.sv are shown below.  

| Signal name | Direction<br/>(from/to this module) | Details |
| :-- | :-- | :-- |
| i_clk         | Input  | Operating clock input.<br/>The transmit/receive baud rate is determined by the i_prer setting based on this clock. |
| i_reset       | Input  | Asynchronous reset input.(Active High) |
| i_rxclear     | Input  | Various receive flags clear input.(Active High) |
| o_rxdata[7:0] | Output | Received data output.<br/>Valid when o_rxdone = High, indeterminate otherwise. |
| o_rxerr       | Output | Receiving error flag output.<br/>High when a receive error occurs. |
| o_rxdone      | Output | Receiving completion flag output.<br/>High when one byte of data is successfully received. |
| i_txrun       | Input  | Transmission start flag input.<br/>Low→High to start i_txdata transmission.<br/>It must always be set Low once before the next data is transmitted. |
| i_txdata[7:0] | Input  | Transmission data input.<br/>Keep the same state for the period from i_txrun = Low→High to o_txdone = High (during transmit operation). |
| o_txdone      | Output | Transmission completion flag output.<br/>High when 1 byte of data is successfully transmitted. |
| i_prer[15:0]  | Input  | Transmit and receive baud rate setting input.<br/>Set the i_clk frequency (Hz) divided by the baud rate (bps).<br/>For example, if you want to set 9600 bps with i_clk=50 MHz,<br/>50,000,000 ÷ 9600 = 5208(dec), so set i_prer = 15'd5208; |
| i_rx          | Input  | UART_RX Input.<br/>Asynchronous signal may be input as it is since it is  synchronized internally. |
| o_tx          | Output | UART_TX Output. |
| o_debug_rxclken | Output | Signal output for debugging. May be left unconnected.<br/>High is output at the timing to latch received data. |
| o_debug_txclken | Output | Signal output for debugging. May be left unconnected.<br/>High is output at the bit timing of the transmitted data. |


## Baud Rate Customization
The parameter rxprer[15:0] in uart_brgene.sv determines the baud rate.  
The counter is cleared when the counter running based on i_clk exceeds rxprer. This frequency determines the baud rate.

This frequency is set to 4 times the transmit/receive baud rate, but the RTL is written to be slightly smaller than the frequency set by i_prpr[15:0] as shown below.

```cpp
always_comb rxprer = ({2'd0, i_prer[15:2]} - {9'd0, i_prer[15:9]} - 16'd1);
```

If this description causes inconvenience, it can be changed to the following description to make the frequency as it should be.

```cpp
always_comb rxprer = ({2'd0, i_prer[15:2]} - 16'd1);
```


## How to control the module
The following is a brief description of how to control this module.


### Settings before transmitting and receiving
The following conditions must be in place prior to transmitting/receiving operations.

- Supply an operating clock to i_clk.
- Set i_reset high for at least one clock period and then set it low.  
  This operation initializes all latches in the module.
- Set i_prer to a value corresponding to the baud rate, then wait for one byte period. 


### Receive operation
When performing the receive operation, perform the operations in the following order.  
To receive multiple bytes of data, repeat this operation.  
Since the next data cannot be received while o_rxdone = High, the key point of control is how to detect this state quickly and prepare for the next reception.

1. Clear various flags as i_rxclear = High, then set to Low.
1. Wait until o_rxdone = High.
1. If o_rxerr = Low, get the received data from o_rxdata.  
  If o_rxerr = High, the reception has failed and the procedure from 1. is repeated to try to receive again.

> This module cannot receive data between the completion of reception and the next start of reception.  
> If data is transmitted continuously at short intervals, the possibility of data being missed increases.


### Transmission Operation
When transmitting, perform the following operations in the order shown below.  
To transmit multiple bytes of data, repeat this operation.

1. If i_txrun = not Low, set Low.
1. Set i_txdata to the data to be transmitted.
1. Set i_txrun = High.
1. Wait until o_txdone = High.

---

## ファイル構成
basic_uart_tmctは以下の4つのファイルによって構成されています。  
ファイル名とそれぞれのファイルの役割を示します。

| File name | Details |
| :-- | :-- |
| uart_tmct_top.sv | 本モジュールのトップレベルファイルです。 |
| uart_brgene.sv | ボーレートジェネレータです。<br/>設定されたボーレートに従って送受信タイミング信号を生成します。 |
| uart_rx.sv | 受信動作およびそのシーケンス制御を行います。 |
| uart_tx.sv | 送信動作およびそのシーケンス制御を行います。 |


## 入出力信号
uart_tmct_top.sv に入出力される信号について詳細を示します。

| Signal name | Direction<br/>(from/to this module) | Details |
| :-- | :-- | :-- |
| i_clk         | Input  | 動作クロック入力です。<br/>送受信ボーレートはこのクロックをもとに i_prer の設定値によって決定されます。 |
| i_reset       | Input  | 非同期リセット入力です。(Active High) |
| i_rxclear     | Input  | 各種受信フラグクリア入力です。(Active High) |
| o_rxdata[7:0] | Output | 受信データが出力されます。<br/>o_rxdone = High のとき有効、それ以外は不定値です。 |
| o_rxerr       | Output | 受信エラーフラグ出力です。<br/>High で受信エラーが発生したことを示します。 |
| o_rxdone      | Output | 受信完了フラグ出力です。<br/>High で1バイトのデータが正常に受信されたことを示します。 |
| i_txrun       | Input  | 送信開始フラグ入力です。<br/>Low→High で i_txdata の送信を開始します。<br/>次のデータを送信する場合は必ずいったん Low にする必要があります。 |
| i_txdata[7:0] | Input  | 送信データ入力です。<br/>i_txrun = Low→High から o_txdone = High までの期間(送信動作中)は同一状態を保持してください。 |
| o_txdone      | Output | 送信完了フラグ出力です。<br/>High で1バイトのデータが正常に送信されたことを示します。 |
| i_prer[15:0]  | Input  | 送受信ボーレート設定入力です。<br/>i_clk の周波数(Hz) を ボーレード(bps) で割った値を設定してください。<br/>たとえば i_clk=50MHz で 9600bps に設定したい場合、<br/>50,000,000 ÷ 9600 = 5208(dec) となるため i_prer = 15'd5208; とします。 |
| i_rx          | Input  | UART_RX 入力です。<br/>内部で同期化されるので非同期信号をそのまま入力して構いません。 |
| o_tx          | Output | UART_TX 出力です。 |
| o_debug_rxclken | Output | デバッグ用の信号出力です。未接続で構いません。<br/>受信データをラッチするタイミングで High が出力されます。 |
| o_debug_txclken | Output | デバッグ用の信号出力です。未接続で構いません。<br/>送信データのビットタイミングで High が出力されます。 |


## ボーレートのカスタマイズ
uart_brgene.sv 内の rxprer[15:0] がボーレートを決定するパラメータです。  
i_clkをベースに動作するカウンタが rxprer を上回るタイミングでカウンタがクリアされます。この頻度によってボーレートが決まります。

この頻度は送受信ボーレートの4倍に設定されますが、RTLでは以下のように i_prpr[15:0] で設定される頻度に対して少しだけ小さめな値となるように記述されています。

```cpp
always_comb rxprer = ({2'd0, i_prer[15:2]} - {9'd0, i_prer[15:9]} - 16'd1);
```

もしこの記述で不都合が生じる場合は、以下の記述に変更することで本来の頻度とすることができます。

```cpp
always_comb rxprer = ({2'd0, i_prer[15:2]} - 16'd1);
```


## モジュールの制御方法
このモジュールの制御方法を簡単に説明します。


### 送受信前の設定
送受信動作を行う前に必ず以下の状態になっている必要があります。  

- i_clk に動作クロックを供給してください。
- i_reset を1クロック期間以上 High にした後、Low にします。  
  この操作でモジュール内のすべてのラッチが初期化されます。
- i_prer にボーレートに応じた値を設定した後、1バイト期間分ウェイトします。  


### 受信動作
受信時は以下の順に操作を行います。  
複数のバイトデータを受信したい場合はこの操作を繰り返します。  
o_rxdone = High の間は次のデータを受信することができないので、いかにこの状態を早く検知して次の受信に備えるかが制御のポイントとなるでしょう。

1. i_rxclear = High として各種フラグをクリアした後、Low にします。
1. o_rxdone = High となるまで待ちます。
1. o_rxerr = Low であれば o_rxdata から受信データを取得します。  
  o_rxerr = High の場合、受信に失敗しているので 1. からの手順を再度行って再受信を試みます。

> このモジュールは受信完了〜次の受信開始までの間はデータを受信することができません。  
> 短い間隔で連続してデータが送信されてくる場合、データの取りこぼしが発生する可能性が高まります。


### 送信動作
送信時は以下の順に操作を行います。  
複数のバイトデータを送信する場合はこの操作を繰り返します。

1. i_txrun = Low でない場合は Low とします。
1. i_txdata に送信したいデータをセットします。
1. i_txrun = High とします。
1. o_txdone = High となるまで待ちます。


