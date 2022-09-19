# Specification: I2C master core module
This module is a port of the I<sup>2</sup>C controller core published on OpenCores.org for openMSP430.  
Although the address maps of the registers are different, the bit assignments within each register are compatible.  
Please refer to the documentation provided with the module for detailed usage.

このモジュールは OpenCores.org で公開されている I<sup>2</sup>C controller core を openMSP430 向けに移植したものです。  
レジスタのアドレスマップは異なりますが、各レジスタ内のビットアサインは互換性があります。  
詳細な使用方法はモジュールに付属のドキュメントをご覧ください。

|  | URL |
| :-- | :-- |
| OpenCores.org | [https://opencores.org](https://opencores.org) |
| I<sup>2</sup>C controller core | [https://opencores.org/projects/i2c](https://opencores.org/projects/i2c) |


## Register map
The register map is shown below.

レジスタマップを以下に示します。

| Address | Reg. name |
| :-- | :-- |
| 0x00b0 | I2C_PRERL |
| 0x00b1 | I2C_PRERH |
| 0x00b2 | I2C_CTR   |
| 0x00b3 | I2C_RXD   |
| 0x00b4 | I2C_SR    |
| 0x00b5 | I2C_TXD   |
| 0x00b6 | I2C_CR    |


### 〔0x00b0〕 I2C_PRERL Register
This register is used to set and get the transmit/receive bit rate. See I2C_PRERH register for details.

送受信ビットレート設定・取得用のレジスタです。詳細は I2C_PRERH レジスタを参照してください。


### 〔0x00b1〕 I2C_PRERH Register
送受信ビットレート設定・取得用のレジスタです。このレジスタが上位8ビット、I2C_PRERL レジスタが下位8ビットの合計16ビットです。  
このモジュールに供給される動作周波数(Hz) を ビットレート(Hz)の5倍 で割った値を設定します。  
たとえば i_clk=50MHz で ビットレート100KHz に設定したい場合、 50,000,000 ÷ (100,000 × 5) = 100(dec) = 0x0064(hex) となるため I2C_PRERH = 0x00; I2C_PRERL = 0x64 とします。


### 〔0x00b2〕 I2C_CTR Register
I2C_CTR レジスタはこのモジュールの動作を開始・停止することができます。

| Bit | R/W | Bit name | Default | Details |
| :-- | :-- | :-- | :-- | :-- |
| 7 | R/W | EN  | 0 | Sets and gets the enable/disable of the I<sup>2</sup>C master core.<br/>I<sup>2</sup>C master coreの有効・無効を設定・取得します。<br/>'1' = Enable  有効<br/>'0' = Disable  無効(停止) |
| 6 | R/W | IEN | 0 | Sets and gets the enable/disable of interrupt output. However, since interrupt output is not implemented at this time, this register does not work.<br/>割り込み出力の有効・無効を設定・取得します。ただし現時点では割り込み出力を実装していないため、このレジスタは機能しません。<br/>'1' = Enable  有効<br/>'0' = Disable  無効 |
| 5 | R   | -   | 0 | Not assigned. |
| 4 | R   | -   | 0 | Not assigned. |
| 3 | R   | -   | 0 | Not assigned. |
| 2 | R   | -   | 0 | Not assigned. |
| 1 | R   | -   | 0 | Not assigned. |
| 0 | R   | -   | 0 | Not assigned. |


### 〔0x00b3〕 I2C_RXD Register
The received data is stored. This register can only retrieve values.

受信されたデータが格納されます。このレジスタは値の取得のみ可能です。


### 〔0x00b4〕 I2C_SR Register
This register is used to obtain the status of the transmit/receive operation and the I2C bus. This register can only retrieve values.

送受信動作およびI2Cバスの状態を取得するためのレジスタです。このレジスタは値の取得のみ可能です。

| Bit | R/W | Bit name | Default | Details |
| :-- | :-- | :-- | :-- | :-- |
| 7 | R | RXACK | - | Indicates the status of ACK reception from the slave device.<br/>スレーブデバイスからのACK受信状態を示します。<br/>'1' = NAK(No ACK)<br/>'0' = ACK |
| 6 | R | BUSY  | - | Indicates I<sup>2</sup>C bus contention status.<br/>I<sup>2</sup>Cバスの競合状態を示します。<br/>'1' = Bus contention exists (send/receive failure)  バス競合あり(送受信失敗)<br/>'0' = No contention  バス競合なし |
| 5 | R | AL    | - | Indicates whether the right to use the bus was taken away during communication.<br/>通信中にバス権が奪われたか示します。<br/>'1' = Bus contention exists (send/receive failure)  バス競合あり(送受信失敗)<br/>'0' = No contention  バス競合なし |
| 4 | R | -     | - | Not assigned. |
| 3 | R | -     | - | Not assigned. |
| 2 | R | -     | - | Not assigned. |
| 1 | R | TIP   | - | Indicates the status of transmit/receive operation.<br/>送受信動作の状態を示します。<br/>'1' = Transmission in progress  送信動作中<br/>'0' = Standby  待機中 |
| 0 | R | IF    | - | Indicates the occurrence of an interrupt. The function of this flag is not yet implemented and may not function properly.<br/>割り込みの発生を示します。このフラグの機能は未実装のため正常に機能しないかもしれません。<br/>'1' = Interrupt occurrence  割り込み発生<br/>'0' = No interruptions occurred  割り込み発生なし |


### 〔0x00b5〕 I2C_TXD Register
Stores the data to be transmitted. This register can also be used to retrieve values.

送信したいデータを格納します。このレジスタは値の取得も可能です。


### 〔0x00b6〕 I2C_CR Register
This register sets the operation of the module.

モジュールの動作を設定するレジスタです。

| Bit | R/W | Bit name | Default | Details |
| :-- | :-- | :-- | :-- | :-- |
| 7 | R/W | STA | 0 | Generates start condition.<br/>開始条件を生成します。<br/>'1' = Generates a start condition  開始条件生成<br/>'0' = Do not generate start condition  開始条件生成なし<br/>This register automatically returns to '0' after the operation is completed.<br/>このレジスタは動作完了後に自動的に'0'に戻ります。 |
| 6 | R/W | STO | 0 | Generates a stop condition and releases the bus.<br/>停止条件を生成してバスを解放します。<br/>'1' = Generates a stop condition  停止条件生成<br/>'0' = Do not generate stop conditions  停止条件生成なし<br/>This register automatically returns to '0' after the operation is completed.<br/>このレジスタは動作完了後に自動的に'0'に戻ります。 |
| 5 | R/W | RD  | 0 | Read from slave.<br/>スレーブデバイスからデータを受信します。<br/>'1' = Read from slave  受信<br/>'0' = Do not read from slave  受信しない<br/>This register automatically returns to '0' after the operation is completed.<br/>このレジスタは動作完了後に自動的に'0'に戻ります。 |
| 4 | R/W | WR  | 0 | Write to slave.<br/>スレーブデバイスにデータを送信します。<br/>'1' = Write to slave  送信<br/>'0' = Do not write to slave  送信しない<br/>This register automatically returns to '0' after the operation is completed.<br/>このレジスタは動作完了後に自動的に'0'に戻ります。 |
| 3 | R/W | ACK | 0 | Transmits ACK to the slave device.<br/>スレーブデバイスにACKを送ります。<br/>'1' = Transmits NACK(No ACK)<br/>'0' = Transmits ACK |
| 2 | R   | -   | 0 | Not assigned. |
| 1 | R   | -   | 0 | Not assigned. |
| 0 | R/W | IACK | 0 | Resets the interrupt generation state (I2C_SR:IF). The function of this flag is not yet implemented and may not function properly.<br/>割り込みの発生状態(I2C_SR:IF)をリセットします。このフラグの機能は未実装のため正常に機能しないかもしれません。<br/>'1' = Interrupt occurrence status clear  割り込み発生状態クリア<br/>'0' = Not clear  クリアしない<br/>This register automatically returns to '0' after the operation is completed.<br/>このレジスタは動作完了後に自動的に'0'に戻ります。 |


## How to use this module
The control and use of this module is shown below.

このモジュールの制御方法・使用方法を以下に示します。


### Initialization
This module must be initialized before use.  
Follow the procedure below to initialize. Upon completion of initialization, this module is ready for transmission and reception.

このモジュールは使用前に初期化が必要です。  
以下の手順で初期化します。初期化が完了次第、本モジュールは送受信完了な状態になります。

1. Stop module operation by setting I2C_CTR:EN = '0'.  
  I2C_CTR:EN = '0' としてモジュールの動作を停止します。
1. Set I2C_PRERH and I2C_PRERL to values corresponding to the bit rate.  
  I2C_PRERH, I2C_PRERL にビットレートに対応する値を設定します。
1. Start module operation by setting I2C_CTR:EN = '1'.  
  I2C_CTR:EN = '1' としてモジュールの動作を開始します。


### Byte write operation
The control method is the same as the I<sup>2</sup>C controller core specification.  
As an example, when 0x34 is written to slave address = 0x51; device internal address 0x12, the I<sup>2</sup>C bus is controlled as follows:

制御方法は I<sup>2</sup>C controller core の仕様と同じです。  
例としてスレーブアドレス = 0x51 のデバイス内アドレス 0x12 に 0x34 を書き込む場合、I<sup>2</sup>Cバスは以下のように制御されます。

1. Generate start condition  
  開始条件を生成する
1. Write slave address(0x51) and write bit(0x01)  
  スレーブアドレス(0x51) と 書き込みビット(0x01) を書き込む
1. Receive acknowledge from slave  
  スレーブデバイスからのACKを受信する
1. Write device internal address(0x12)  
  デバイス内アドレス(0x12)を書き込む
1. Receive acknowledge from slave  
  スレーブデバイスからのACKを受信する
1. Write data(0x34)  
  データ(0x34)を書き込む
1. Receive acknowledge from slave  
  スレーブデバイスからのACKを受信する
1. Generate stop condition  
  停止条件を生成する

To do this with this module, control each register as follows:
これを本モジュールで行うためには、各レジスタを以下のように制御します。

1. Set 0xa2 (slave address[7:1]:0x51 + write bit[0]:0x00) to I2C_TXD.  
  I2C_TXD に 0xa2 (スレーブアドレス[7:1]:0x51 + 書き込みビット[0]:0x00) をセットします。
1. Set I2C_CR:STA bit and I2C_CR:WR bit to '1'.  
  I2C_CR:STA と I2C_CR:WR に '1' をセットします。
1. Wait for I2C_SR:TIP flag to '0'.  
  I2C_SR:TIP = '0' となるのを待ちます。
1. Read I2C_SR:RXACK bit, should be ‘0’.  
  I2C_SR:RXACK が 0 になっているはずなので確認します。
1. Set 0x12 to I2C_TXD.  
  I2C_TXD に 0x12 をセットします。
1. Set I2C_CR:WR bit to '1'.  
  I2C_CR:WR に '1' をセットします。
1. Wait for I2C_SR:TIP flag to '0'.  
  I2C_SR:TIP = '0' となるのを待ちます。
1. Read I2C_SR:RXACK bit, should be 0, but response varies by device.  
  I2C_SR:RXACK が 0 になっているか確認します。(ただしデバイスによって挙動が異なります)
1. Set 0x34 to I2C_TXD.  
  I2C_TXD に 0x34 をセットします。
1. Set I2C_CR:STO bit and I2C_CR:WR bit to '1'.  
  I2C_CR:STO と I2C_CR:WR に '1' をセットします。
1. Wait for I2C_SR:TIP flag to '0'.  
  I2C_SR:TIP = '0' となるのを待ちます。
1. Read I2C_SR:RXACK bit, should be 0, but response varies by device.  
  I2C_SR:RXACK が 0 になっているか確認します。(ただしデバイスによって挙動が異なります)


### Byte read operation
The control method is the same as the I<sup>2</sup>C controller core specification.  
As an example, to read the value of slave address = 0x4e; device internal address 0x20, the I<sup>2</sup>C bus is controlled as follows:

制御方法は I<sup>2</sup>C controller core の仕様と同じです。  
例としてスレーブアドレス = 0x4e のデバイス内アドレス 0x20 の値を読みたい場合、I<sup>2</sup>Cバスは以下のように制御されます。

1. Generate start condition  
  開始条件を生成する
1. Write slave address(0x4e) and write bit(0x00)  
  スレーブアドレス(0x4e) と 書き込みビット(0x00) を書き込む
1. Receive acknowledge from slave  
  スレーブデバイスからのACKを受信する
1. Write device internal address(0x20)  
  デバイス内アドレス(0x20)を書き込む
1. Receive acknowledge from slave  
  スレーブデバイスからのACKを受信する
1. Generate repeated start condition  
  再度開始条件を生成する
1. Write slave address(0x4e) and read bit(0x00)  
  スレーブアドレス(0x4e) と 読み込みビット(0x00) を書き込む
1. Receive acknowledge from slave  
  スレーブデバイスからのACKを受信する
1. Read byte from slave  
  スレーブデバイスからデータを読み取る
1. Write no acknowledge (NACK) to slave, indicating end of transfer  
  転送終了を示すためデバイスにNACKで応答する
1. Generate stop condition
  停止条件を生成する

To do this with this module, control each register as follows:  
これを本モジュールで行うためには、各レジスタを以下のように制御します。

1. Set 0x9c (slave address[7:1]:0x4e + write bit[0]:0x00) to I2C_TXD.  
  I2C_TXD に 0x9c (スレーブアドレス[7:1]:0x4e + 書き込みビット[0]:0x00) をセットします。
1. Set I2C_CR:STA bit and I2C_CR:WR bit to '1'.  
  I2C_CR:STA と I2C_CR:WR に '1' をセットします。
1. Wait for I2C_SR:TIP flag to '0'.  
  I2C_SR:TIP = '0' となるのを待ちます。
1. Read I2C_SR:RXACK bit, should be ‘0’.  
  I2C_SR:RXACK が 0 になっているはずなので確認します。
1. Set 0x12 to I2C_TXD.  
  I2C_TXD に 0x20 をセットします。
1. Set I2C_CR:WR bit to '1'.  
  I2C_CR:WR に '1' をセットします。
1. Wait for I2C_SR:TIP flag to '0'.  
  I2C_SR:TIP = '0' となるのを待ちます。
1. Read I2C_SR:RXACK bit, should be 0, but response varies by device.  
  I2C_SR:RXACK が 0 になっているか確認します。(ただしデバイスによって挙動が異なります)
1. Set 0x9d (slave address[7:1]:0x4e + read bit[0]:0x01) to I2C_TXD.  
  I2C_TXD に 0x9d (スレーブアドレス[7:1]:0x4e + 読み込みビット[0]:0x01) をセットします。
1. Set I2C_CR:STA bit and I2C_CR:WR bit to '1'.  
  I2C_CR:STA と I2C_CR:WR に '1' をセットします。
1. Wait for I2C_SR:TIP flag to '0'.  
  I2C_SR:TIP = '0' となるのを待ちます。
1. Set I2C_CR:RD bit, I2C_CR:ACK bit and I2C_CR:STO bit to '1'.  
  I2C_CR:RD と I2C_CR:ACK と I2C_CR:STO に '1' をセットします。
1. Get the receive data stored in I2C_RXD.  
  I2C_RXDに格納された受信データを取得します。

