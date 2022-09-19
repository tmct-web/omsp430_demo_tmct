# omsp430_demo_tmct
opemMSP430 Demo project  
[日本語はこちら](#anchor0_ja)

This repository is a porting of openMSP430 to Terasic DE0 and DE0CV.  
It is released as a Quartus Prime project.  
This project includes a UART (basic_uart_tmct) freely available from firmware, an I<sup>2</sup>C master ([I2C controller core](https://opencores.org/projects/i2c)) and basic firmware to use them from the uart debug console, so you can start using it immediately as a base project for your FPGA-embedded microcontroller core.  

openMSP430 を Terasic DE0 および DE0CV にフィッティングしたものをQuartus Primeのプロジェクトごと公開します。  
このプロジェクトには、ファームウェアから自由に使用できるUART(basic_uart_tmct)、I<sup>2</sup>Cマスタ([I2C controller core](https://opencores.org/projects/i2c)) および それらをuartデバッグコンソールから利用するためのファームウェアを内蔵しているため、FPGA内蔵マイコンコアのベースプロジェクトとしてすぐに使い始めることができます。  
※日本語の解説文は[英語の後](#anchor0_ja)にあります。  
※開発環境の構築などさらに詳しく知りたい方は[こちら](https://ss1.xrea.com/tmct.s1009.xrea.com/doc/ta-ja-7e6h01.html)をどうぞ。  

---
## Table Of Contents
- [What is openMSP430?](#anchor1_en)
- [Contents of this demo project](#anchor2_en)
- [Default configuration of the demo project](#anchor3_en)
- [Hardware assignment](#anchor4_en)
- [Using the UART debug console](#anchor5_en)


<a id="anchor1_en"></a>

## What is openMSP430?
openMSP430 is a so-called soft-core CPU that reproduces the functions of the MSP430 microcontroller (developed and sold by Texas Instruments) on FPGA. It is available free of charge.  
Many people may think that "a free soft-core CPU that can be implemented in FPGA" sounds "fishy" or "it has strange restrictions and cannot be used properly anyway," but it works properly.  
The features are roughly as follows:

- **Free public release under the BSD license**.  
  openMSP430 is released under the BSD license, which means that there is no obligation to release development results. Also, as long as the copyright is not erased, it can be used and distributed with almost no restrictions.  
  If used well, it will greatly contribute to improving the productivity of not only DIY but also mass-produced products.
- **All development environments, including gcc-based compilers, are available for free**.  
  No money is required to build the software environment.  
  (...although the gcc-based development environment is maintained by Texas Instruments, so contribute to sales in some way...)
- **The documentation is very well written**.  
  The developer, Girard Olivier, has described the documentation very carefully, and just reading the documentation is quite enough to deepen your understanding.
- **Works properly with real FPGA (Important!)**  
  Surprisingly, there are many soft-core CPUs that only work properly in simulation because developers are only interested in developing CPU cores. Such projects naturally do not work properly in real FPGAs.  
  The openMSP430 has been verified to work properly on real FPGAs and includes a debugger and other tools.

openMSP430 itself is available free of charge at the following site.  
It is very gratifying to be provided with such a useful core at free of charge.

| Site | Link |
| :--- | :--- |
| OpenCores.org | [https://opencores.org/projects/openmsp430](https://opencores.org/projects/openmsp430) |
| GitHub | [https://github.com/olgirard/openmsp430](https://github.com/olgirard/openmsp430) |


<a id="anchor2_en"></a>

## Contents of this demo project
The contents of omsp430_demo_tmct are generally as follows.  
Note that some folders are omitted from the following, but it is not intended that they are not written because they are not needed. So please be very careful when deleting them.  

| Folder | Details |
| :-- | :-- |
| /board/terasic_de0 | The main components are:<br/>- Project files for Terasic DE0(Intel CycloneIII EP3C16F484C6)<br/>- IP core (PLL, program memory, and data memory)<br/>- Top-level file(omsp430_demo_top.v)<br/>- openMSP430 configuration definition file(openMSP430_defines.v) |
| /board/terasic_de0cv | The main components are:<br/>- Project files for Terasic DE0CV(Intel CycloneV 5CEBA4F23C7)<br/>- IP core (PLL, program memory, and data memory)<br/>- Top-level file(omsp430_demo_top.v)<br/>- openMSP430 configuration definition file(openMSP430_defines.v) |
| /doc | It contains links to the documentation included in the demo project. |
| /firmware | The main components are:<br/>- Sample firmware source code(.c; .h)<br/>- makefile<br/>- Linker script(.x)<br/>- Batch files for development environment(dev.bat) |
| /firmware/bin | It contains a program and source code to convert a bin file to a mif file.<br/>The program is called and used at make time. |
| /firmware/obj | This is the folder where intermediate object files (.o) are generated during compilation. |
| /firmware/output | This is the folder where the final product files (.bin; .mif) are generated during compilation. |
| /firmware/tools/bin | It includes TCL scripts used primarily for debugging. |
| /firmware/tools/lib | Contains libraries for running TCL scripts. |
| /rtl/basic_uart_tmct | A core of basic UART functionality is included. <br/>More details about the core can be found in readme.md. |
| /rtl/i2c_master | It includes the core part of the I<sup>2</sup>C controller core published at [OpenCores.org](https://opencores.org).<br/>[I2C controller core](https://opencores.org/projects/i2c) |
| /rtl/omsp430 | The contents of the */trunk/core/rtl* folder in openMSP430 are included as is.<br/>However, the following files are not used in this demo project:<br/>- /rtl/omsp430/periph/*<br/>- openMSP430_defines.v<br/>※openMSP430_defines.v placed under the */board* folder will be used. |
| /rtl/omsp430_periph_regs | It includes register sections related to GPIO, UART, and I<sup>2</sup>C. |


<a id="anchor3_en"></a>

## Default configuration of the demo project
The configuration and functions of the demo project are configured as follows without any modification.  
Since the UART and I<sup>2</sup>C master function are connected to the peripheral bus, it should be possible to do almost as well as a normal one-chip microcontroller as it is.  

| Item | Details |
| :-- | :-- |
| Program memory | 16k Bytes (8k words) |
| Data memory | 4k Bytes (2k words) |
| Peripheral area size  | 512 Bytes |
| Hardware break point | Disabled |
| Debug interface | UART |
| IRQ | ×13 |
| UART interface | ×1 |
| I<sup>2</sup>C master interface | ×1 |
| GPIO | 8bit × 2 |

　

The sample firmware implements a uart debug console that can run a full set of hardware by issuing commands from the serial communication terminal.  
It can be referenced as a sample of control over the implemented hardware.


<a id="anchor4_en"></a>

## Hardware assignment
The following assignments are made for devices and pins on the board.  
Please refer to the pin assignment file included in the project for the pin assignment of each FPGA.

| Item | Direction | Details |
| :-- | :-- | :-- |
| Key0(Button0) | Input | Press to reset |
| Key1(Button1) | Input | IRQ0 interrupt occurs when pressed<br/>*Multiple interrupts due to chattering may cause the microcontroller to malfunction. |
| Key2(Button2) | Input | IRQ1 interrupt occurs when pressed<br/>*Multiple interrupts due to chattering may cause the microcontroller to malfunction. |
| Slide switch 7～0 | Input | PORT00[7:0] |
| LED7～0 | Output | PORT01[7:0] |
| LED8 | Output | DEBUG_FREEZE<br/>Lights up when CPU is paused by debugger |
| LED9 | Output | PLL_LOCKED<br/>Lights up in PLL locked |
| GPIO1-22pin | Input | UART for Debugger:RX<br/>If using TCL script debugger, connect USB-UART converter etc. here |
| GPIO1-24pin | Output | UART for Debugger:TX<br/>If using TCL script debugger, connect USB-UART converter etc. here |
| GPIO1-26pin | Input | UART for firmware:RX<br/>UART interface accessible from firmware(basic_uart_tmct)<br/>*If using uart debug console, connect USB-UART converter, etc. here |
| GPIO1-28pin | Output | UART for firmware:TX<br/>UART interface accessible from firmware(basic_uart_tmct)<br/>*If using uart debug console, connect USB-UART converter, etc. here |
| GPIO1-38pin | Output | I<sup>2</sup>C master:SCL<br/>Connect I<sup>2</sup>C device here (external PullUp required) |
| GPIO1-40pin | InOut | I<sup>2</sup>C master:SDA<br/>Connect I<sup>2</sup>C device here (external PullUp required) |


<a id="anchor5_en"></a>

## Using the UART debug console
Using the UART debug console implemented as firmware, the hardware can be accessed via text-based command.  
The communication specifications are as follows.  
To use, connect the COM port (or USB-COM converter) of the PC to the above "UART for firmware". (*Not UART for debugger)

- **Baud-rate:** 38400
- **Start bits:** 1 bit
- **Data bits:** 8 bit
- **Stop bits:** 1 bit
- **Parity bit:** None
- **Flow control:** None
- **Line feed code:**  
  Receive = CR or LF  
  Transmit = CR + LF

　

When the serial console firmware is successfully activated, '>' is output from the UART and the device enters a state waiting for input.  
When a linefeed code is input following a control command, the unit performs the operation corresponding to that command, then outputs '>' again and enters the input waiting state.  
If it has a return value, it is output before '>'.  
The feeling of operation is similar to the Windows prompt or the macOS shell.

The control commands and their formats are shown below.  
Parameters are in hexadecimal and all digits are fixed; leading zeros in a 2-byte parameter cannot be omitted.  
For example, to write 0x01 to address 0x90 in the CPU bus space, send sw009001[CR].  

| Command | Format | Details |
| :-- | :-- | :-- |
| sr  | srxxxx   | **Reads the value of the specified address in the CPU bus space**<br/>xxxx = Address (4-digit hexadecimal ASCII character) |
| sw  | swxxxxyy | **Writes a value to a specified address in the CPU bus space**<br/>xxxx = Address (4-digit hexadecimal ASCII character)<br/>yy = Value (2-digit hexadecimal ASCII character) |
| pr  | prxx     | **Read value from GPIO**<br/>xx = Port number<br/>Only 00 and 01 are supported in this hardware configuration. |
| pw  | pwxxyy   | **Write value to GPIO**<br/>xx = Port number(Only 01 works properly)<br/>yy = Value (2-digit hexadecimal ASCII character) |
| ir  | irxxyy   | **Reads the value of the specified device and specified address on the I<sup>2</sup>C bus**<br/>xx = Slave address (2-digit hexadecimal ASCII character)<br/>yy = Address in device (2-digit hexadecimal ASCII character) |
| iw  | iwxxyyzz | **Writes a value to the specified device and specified address on the I<sup>2</sup>C bus**<br/>xx = Slave address (2-digit hexadecimal ASCII character)<br/>yy = Address in device (2-digit hexadecimal ASCII character)<br/>zz = Value (2-digit hexadecimal ASCII character) |


---
<a id="anchor0_ja"></a>

## 目次
- [openMSP430って何よ？](#anchor1_ja)
- [デモプロジェクトの中身](#anchor2_ja)
- [デモプロジェクトのコンフィグレーション](#anchor3_ja)
- [ハードウェアのアサイン](#anchor4_ja)
- [UARTデバッグコンソールを使う](#anchor5_ja)


<a id="anchor1_ja"></a>

## openMSP430って何よ？
openMSP430はTexas Instrumentsが開発・販売している**MSP430マイコンの機能をFPGA上で再現したもの**で、無償で公開されているいわゆるソフトコアCPUです。  
「FPGAに実装可能な無償のソフトコアCPU」と聞くと『胡散臭い』『どうせ変な制約があってマトモに使えないだろう』と邪推する人も多いでしょうが、**マトモに動きます**。  
ざっくり以下のような特徴があります。

- **BSDライセンスで無償公開されている**  
  openMSP430はBSDライセンスで公開されており、開発成果物を公開する義務がありません。また、著作権を消さない限りはほぼ制約なく利用・配布することができます。  
  うまく利用すればDIYだけでなく量産製品の生産性向上にも大きく寄与することでしょう。
- **開発環境はgccベースのコンパイラなど含めすべて無償で入手できる**  
  ソフトウェア環境の構築にはいっさいお金はかかりません。  
  (…とはいえgccベースの開発環境はTexas Instrumentsがメンテナンスしてくれているので何らかの形で売上に貢献しましょう。)
- **ドキュメントが非常に詳しく書かれている**  
  開発者のGirard Olivierさんが非常に丁寧にドキュメントを記載してくれており、ただドキュメントを読み込むだけでもかなり理解を深めることができます。  
  英語の勉強にもなりますしね(ニッコリ)
- **実FPGAできちんと動作する(重要！)**  
  ソフトコアCPUの中には、開発者がCPUコアを開発することしか興味がなく「シミュレーション上は動いてますが、実際のFPGA上でプログラムが動くことは確認してません。する予定もありません。(おわり)」みたいなものが意外と多くあります。  
  openMSP430は実FPGAでもきちんと動作することが確認されている上、デバッガなども同梱されています。

openMSP430自体は以下のサイトで無償公開されています。  
このような有用なコアを無償で提供して頂いていることに感謝します。

| Site | Link |
| :--- | :--- |
| OpenCores.org | [https://opencores.org/projects/openmsp430](https://opencores.org/projects/openmsp430) |
| GitHub | [https://github.com/olgirard/openmsp430](https://github.com/olgirard/openmsp430) |


<a id="anchor2_ja"></a>

## デモプロジェクトの中身
omsp430_demo_tmctの中身は概ね以下のようになっています。  
なお、以下からは省略しているフォルダもありますが、要らないから書いてないという意図ではないので削除する場合は十分に注意してください。  

| Folder | Details |
| :-- | :-- |
| /board/terasic_de0 | 主に以下が含まれます:<br/>- Terasic DE0(Intel CycloneIII EP3C16F484C6)向けのプロジェクトファイル<br/>- PLL・プログラムメモリ・データメモリのIPコア<br/>- トップレベルファイル(omsp430_demo_top.v)<br/>- openMSP430の構成定義ファイル(openMSP430_defines.v) |
| /board/terasic_de0cv | 主に以下が含まれます:<br/>- Terasic DE0CV(Intel CycloneV 5CEBA4F23C7)向けのプロジェクトファイル<br/>- PLL・プログラムメモリ・データメモリのIPコア<br/>- トップレベルファイル(omsp430_demo_top.v)<br/>- openMSP430の構成定義ファイル(openMSP430_defines.v) |
| /doc | デモプロジェクトに含まれるドキュメントへのリンクが格納されています。 |
| /firmware | 以下が含まれます:<br/>- サンプルファームウェアのソースコード(*.c; *.h)<br/>- makeファイル<br/>- リンカースクリプト<br/>- 開発環境用のバッチファイル(dev.bat) |
| /firmware/bin | *.binファイルをmifファイルに変換するためのプログラムとソースコードが含まれます。<br/>プログラムは make 時に呼び出されて使用されます。 |
| /firmware/obj | コンパイルの際、中間オブジェクトファイル(*.o)が生成されます。 |
| /firmware/output | コンパイルの際、最終成果物ファイル(*.bin; *.mif)が生成されます。 |
| /firmware/tools/bin | 主にデバッグ時に使用するTCLスクリプトが含まれます。 |
| /firmware/tools/lib | TCLスクリプトを実行するためのライブラリが含まれます。 |
| /rtl/basic_uart_tmct | ごく基本的なUART機能のコアが含まれます。<br/>コアについての詳細は readme.md に詳細が記載しています。 |
| /rtl/i2c_master | [OpenCores.org](https://opencores.org)で公開されているI<sup>2</sup>C controller core のコア部分が含まれます。<br/>[I2C controller core](https://opencores.org/projects/i2c) |
| /rtl/omsp430 | openMSP430 の */trunk/core/rtl* フォルダの中身がそのまま含まれます。<br/>以下のファイルはこのデモプロジェクトでは使用されません。<br/>- /rtl/omsp430/periph/*<br/>- openMSP430_defines.v<br/>※openMSP430_defines.v は */board* 以下にある各ボード向けのものが使用されます。 |
| /rtl/omsp430_periph_regs | GPIO・UART・I<sup>2</sup>Cに関連するレジスタ部分が含まれます。 |


<a id="anchor3_ja"></a>

## デモプロジェクトのコンフィグレーション
デモプロジェクトのコンフィグレーションや機能は何もいじらない状態では以下の通り構成されています。  
ペリフェラルバスに UART と I<sup>2</sup>Cマスター機能 を接続しているので、このままでもほぼ普通のワンチップマイコンと遜色ないことはできるはず。  

| Item | Details |
| :-- | :-- |
| プログラムメモリ | 16k Bytes (8k words) |
| データメモリ | 4k Bytes (2k words) |
| ペリフェラル領域  | 512 Bytes |
| ハードウェアブレークポイント | 無効 |
| デバッグインターフェイス | UART |
| IRQ | ×13 |
| UARTインターフェイス | ×1 |
| I<sup>2</sup>C マスタインターフェイス | ×1 |
| GPIO | 8bit × 2 |

　

サンプルファームウェアにはシリアル通信ターミナルからのコマンド発行でハードウェアを一通り動かすことができるシリアルコンソールが実装されています。  
実装されたハードウェアに対する制御のサンプルとして参照するとよいでしょう。


<a id="anchor4_ja"></a>

## ハードウェアのアサイン
ボード上のデバイスやピンに対しては以下のようにアサインされています。  
各FPGAのピンアサインはプロジェクトに含まれるピンアサインファイルをご覧ください。

| Item | Direction | Details |
| :-- | :-- | :-- |
| Key0(Button0) | Input | 押下でリセット |
| Key1(Button1) | Input | 押下でIRQ0割り込み発生 |
| Key2(Button2) | Input | 押下でIRQ1割り込み発生 |
| スライドスイッチ 7～0 | Input | PORT00[7:0] |
| LED7～0 | Output | PORT01[7:0] |
| LED8 | Output | DEBUG_FREEZE<br/>※デバッガによるCPU停止中に点灯 |
| LED9 | Output | PLL_LOCKED<br/>※PLLロックで点灯 |
| GPIO1-22pin | Input | デバッガ用UART:RX<br/>※TCLスクリプトのデバッガを使用する場合はUSB-UART変換などをここに接続 |
| GPIO1-24pin | Output | デバッガ用UART:TX<br/>※TCLスクリプトのデバッガを使用する場合はUSB-UART変換などをここに接続 |
| GPIO1-26pin | Input | ファームウェア用UART:RX<br/>※ファームウェアからアクセス可能なUARTインターフェイス(basic_uart_tmct)<br/>※シリアルコンソールを利用する場合はUSB-UART変換などをここに接続 |
| GPIO1-28pin | Output | ファームウェア用UART:TX<br/>※ファームウェアからアクセス可能なUARTインターフェイス(basic_uart_tmct)<br/>※シリアルコンソールを利用する場合はUSB-UART変換などをここに接続 |
| GPIO1-38pin | Output | I<sup>2</sup>Cマスタ:SCL<br/>※I<sup>2</sup>Cデバイスをここに接続(外部Pull Up抵抗必要) |
| GPIO1-40pin | InOut | I<sup>2</sup>Cマスタ:SDA<br/>※I<sup>2</sup>Cデバイスをここに接続(外部Pull Up抵抗必要) |


<a id="anchor5_ja"></a>

## UARTデバッグコンソールを使う
ファームウェアとして実装されているUARTデバッグコンソールを使用すると、ファームウェア用UARTからテキストベースのコマンド授受によってハードウェアにアクセスすることができます。  
通信仕様は以下の通りです。  
使用する場合は上記「ファームウェア用UART」にパソコンのCOMポート(またはUSB-COM変換)を接続します。(※デバッガ用UARTではありません)

- **Baud-rate:** 38400
- **Start bits:** 1 bit
- **Data bits:** 8 bit
- **Stop bits:** 1 bit
- **Parity bit:** None
- **Flow control:** None
- **Line feed code:**  
  Receive = CR or LF  
  Transmit = CR + LF

　

シリアルコンソールファームウェアが正常に起動するとUARTから > が出力され、入力待ち状態になります。  
制御コマンドに続いてラインフィードコードが入力されるとそのコマンドに応じた動作を行った後、再び > を出力して入力待ち状態になります。  
戻り値がある場合は > の前に出力されます。  
操作感としてはWindowsのプロンプトやmacOSのシェルなどと同じようなイメージです。

制御コマンドとその書式を以下に示します。  
パラメータは16進数かつ桁数はすべて固定です。2バイトのパラメータの先頭ゼロを省略して与えることはできません。  
たとえばCPUバス空間のアドレス 0x90 に 0x01 を Write する場合、 sw009001[CR] を送ります。

| Command | Format | Details |
| :-- | :-- | :-- |
| sr  | srxxxx   | **CPUバス空間の指定アドレスの値をReadします**<br/>xxxx = アドレス(4桁の16進数ASCII文字) |
| sw  | swxxxxyy | **CPUバス空間の指定アドレスに値をWriteします**<br/>xxxx = アドレス(4桁の16進数ASCII文字)<br/>yy = 値(2桁の16進数ASCII文字) |
| pr  | prxx     | **GPIOから値をReadします**<br/>xx = ポート番号<br/>このハードウェア構成では 00 と 01 のみサポートしています。 |
| pw  | pwxxyy   | **GPIOに値をWriteします**<br/>xx = ポート番号(01 のみ正常に機能します)<br/>yy = 値(2桁の16進数ASCII文字) |
| ir  | irxxyy   | **I<sup>2</sup>Cバスの指定デバイス・指定アドレスの値をReadします**<br/>xx = スレーブアドレス(2桁の16進数ASCII文字)<br/>yy = デバイス内のアドレス(2桁の16進数ASCII文字) |
| iw  | iwxxyyzz | **I<sup>2</sup>Cバスの指定デバイス・指定アドレスに値をWriteします**<br/>xx = スレーブアドレス(2桁の16進数ASCII文字)<br/>yy = デバイス内のアドレス(2桁の16進数ASCII文字)<br/>zz = 値(2桁の16進数ASCII文字) |


## さらに詳しく知る
開発環境の構築などさらに詳しく知りたい方はこちらをどうぞ。  

[tmct web-site: openMSP430を使ってみる［導入・開発環境整備編］](https://ss1.xrea.com/tmct.s1009.xrea.com/doc/ta-ja-7e6h01.html)

