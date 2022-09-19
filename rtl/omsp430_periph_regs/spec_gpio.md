# Specification: Basic GPIO module
The Basic GPIO module provides 8-bit × 2 bidirectional digital I/O functionality.  
The input/output direction can be set arbitrarily for each bit by register settings.

Basic GPIOモジュールは 8bit × 2系統の双方向デジタルI/O機能を提供します。  
入出力の方向はレジスタ設定によってビットごとに任意に設定することができます。  

## Register map
The register map is shown below.

レジスタマップを以下に示します。

| Address | Reg. name |
| :-- | :-- |
| 0x0090 | GPIO_P00     |
| 0x0091 | GPIO_P00_DIR |
| 0x0092 | GPIO_P01     |
| 0x0093 | GPIO_P01_DIR |


### 〔0x0090〕 GPIO_P00 Register
The GPIO_P00 register is used to set and retrieve the GPIO Port00 status.  
For the bits set to output by GPIO_P00_DIR, the value written to this register is output to Port00. (This does not affect the bits set to input.)  
When this register is read, the status of Port00 can be obtained.

GPIO_P00 レジスタは GPIO Port00 の状態を設定・取得するためのレジスタです。  
GPIO_P00_DIR で出力に設定したビットに対しては、このレジスタに Write した値が Port00 に出力されます。(入力に設定したビットに対しては影響しません)  
このレジスタを Read すると Port00 の状態を取得することができます。

| Bit | R/W | Bit name | Default | Details |
| :-- | :-- | :-- | :-- | :-- |
| 7  | R/W | GPIO_P00[7] | 0 | Sets and gets the output status of Port00[7].<br/>Port00[7] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 6  | R/W | GPIO_P00[6] | 0 | Sets and gets the output status of Port00[6].<br/>Port00[6] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 5  | R/W | GPIO_P00[5] | 0 | Sets and gets the output status of Port00[5].<br/>Port00[5] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 4  | R/W | GPIO_P00[4] | 0 | Sets and gets the output status of Port00[4].<br/>Port00[4] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 3  | R/W | GPIO_P00[3] | 0 | Sets and gets the output status of Port00[3].<br/>Port00[3] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 2  | R/W | GPIO_P00[2] | 0 | Sets and gets the output status of Port00[2].<br/>Port00[2] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 1  | R/W | GPIO_P00[1] | 0 | Sets and gets the output status of Port00[1].<br/>Port00[1] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 0  | R/W | GPIO_P00[0] | 0 | Sets and gets the output status of Port00[0].<br/>Port00[0] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |


### 〔0x0091〕 GPIO_P00_DIR Register
The GPIO_P00_DIR register is used to set and retrieve the inputs and outputs of the GPIO Port00.  
Bits set to '0' are inputs and bits set to '1' are outputs.

GPIO_P00_DIR レジスタは GPIO Port00 の入出力を設定・取得するためのレジスタです。  
'0' に設定されたビットは入力、'1' に設定されたビットは出力になります。

| Bit | R/W | Bit name | Default | Details |
| :-- | :-- | :-- | :-- | :-- |
| 7  | R/W | GPIO_P00_DIR[7] | 0 | Sets and gets the input/output direction of Port00[7].<br/>Port00[7] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 6  | R/W | GPIO_P00_DIR[6] | 0 | Sets and gets the input/output direction of Port00[6].<br/>Port00[6] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 5  | R/W | GPIO_P00_DIR[5] | 0 | Sets and gets the input/output direction of Port00[5].<br/>Port00[5] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 4  | R/W | GPIO_P00_DIR[4] | 0 | Sets and gets the input/output direction of Port00[4].<br/>Port00[4] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 3  | R/W | GPIO_P00_DIR[3] | 0 | Sets and gets the input/output direction of Port00[3].<br/>Port00[3] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 2  | R/W | GPIO_P00_DIR[2] | 0 | Sets and gets the input/output direction of Port00[2].<br/>Port00[2] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 1  | R/W | GPIO_P00_DIR[1] | 0 | Sets and gets the input/output direction of Port00[1].<br/>Port00[1] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 0  | R/W | GPIO_P00_DIR[0] | 0 | Sets and gets the input/output direction of Port00[0].<br/>Port00[0] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |


### 〔0x0092〕 GPIO_P01 Register
The GPIO_P01 register is used to set and retrieve the GPIO Port01 status.  
For the bits set to output by GPIO_P01_DIR, the value written to this register is output to Port01. (This does not affect the bits set to input.)  
When this register is read, the status of Port01 can be obtained.

GPIO_P01 レジスタは GPIO Port01 の状態を設定・取得するためのレジスタです。  
GPIO_P01_DIR で出力に設定したビットに対しては、このレジスタに Write した値が Port01 に出力されます。(入力に設定したビットに対しては影響しません)  
このレジスタを Read すると Port01 の状態を取得することができます。

| Bit | R/W | Bit name | Default | Details |
| :-- | :-- | :-- | :-- | :-- |
| 7  | R/W | GPIO_P01[7] | 0 | Sets and gets the output status of Port01[7].<br/>Port01[7] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 6  | R/W | GPIO_P01[6] | 0 | Sets and gets the output status of Port01[6].<br/>Port01[6] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 5  | R/W | GPIO_P01[5] | 0 | Sets and gets the output status of Port01[5].<br/>Port01[5] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 4  | R/W | GPIO_P01[4] | 0 | Sets and gets the output status of Port01[4].<br/>Port01[4] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 3  | R/W | GPIO_P01[3] | 0 | Sets and gets the output status of Port01[3].<br/>Port01[3] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 2  | R/W | GPIO_P01[2] | 0 | Sets and gets the output status of Port01[2].<br/>Port01[2] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 1  | R/W | GPIO_P01[1] | 0 | Sets and gets the output status of Port01[1].<br/>Port01[1] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |
| 0  | R/W | GPIO_P01[0] | 0 | Sets and gets the output status of Port01[0].<br/>Port01[0] の出力状態を設定・取得します。<br/>'1' = High<br/>'0' = Low |


### 〔0x0093〕 GPIO_P01_DIR Register
The GPIO_P01_DIR register is used to set and retrieve the inputs and outputs of the GPIO Port01.  
Bits set to '0' are inputs and bits set to '1' are outputs.

GPIO_P01_DIR レジスタは GPIO Port01 の入出力を設定・取得するためのレジスタです。  
'0' に設定されたビットは入力、'1' に設定されたビットは出力になります。

| Bit | R/W | Bit name | Default | Details |
| :-- | :-- | :-- | :-- | :-- |
| 7  | R/W | GPIO_P01_DIR[7] | 0 | Sets and gets the input/output direction of Port01[7].<br/>Port01[7] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 6  | R/W | GPIO_P01_DIR[6] | 0 | Sets and gets the input/output direction of Port01[6].<br/>Port01[6] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 5  | R/W | GPIO_P01_DIR[5] | 0 | Sets and gets the input/output direction of Port01[5].<br/>Port01[5] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 4  | R/W | GPIO_P01_DIR[4] | 0 | Sets and gets the input/output direction of Port01[4].<br/>Port01[4] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 3  | R/W | GPIO_P01_DIR[3] | 0 | Sets and gets the input/output direction of Port01[3].<br/>Port01[3] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 2  | R/W | GPIO_P01_DIR[2] | 0 | Sets and gets the input/output direction of Port01[2].<br/>Port01[2] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 1  | R/W | GPIO_P01_DIR[1] | 0 | Sets and gets the input/output direction of Port01[1].<br/>Port01[1] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |
| 0  | R/W | GPIO_P01_DIR[0] | 0 | Sets and gets the input/output direction of Port01[0].<br/>Port01[0] の入出力を設定・取得します。<br/>'1' = 出力<br/>'0' = 入力 |


## How to use this module
After reset, all pins of both Port00 and Port01 are set to input. Set the initial output values and input/output direction before use.  
The following procedure is recommended.

リセット後は Port00・Port01 ともすべての端子が入力に設定されます。使用前に出力初期値と入出力方向を設定してください。  
以下の手順で行うことを推奨します。

1. Set the initial output value to GPIO_P00.  
  GPIO_P00 に出力初期値を設定する。
1. Set the initial output value to GPIO_P01.  
  GPIO_P01 に出力初期値を設定する。
1. Set the input/output direction to GPIO_P00_DIR.  
  GPIO_P00_DIR に入出力方向を設定する。
1. Set the input/output direction to GPIO_P01_DIR.  
  GPIO_P01_DIR に入出力方向を設定する。

> To prevent malfunction of the negative logic circuit, it is recommended to set the initial output value before setting the input/output direction.  
> 負論理回路の誤動作を防ぐため、上記のように出力初期値を設定してから入出力方向を設定することをお勧めします。  

