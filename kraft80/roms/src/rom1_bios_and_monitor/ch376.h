PORTBUTTONS	.equ	0x00	
PORTLEDS	.equ	0x00	

; FPGA addr mapping (base 0x50)
; 0000: Video RAM Data (R/W)
; 0001: Video ADDR Low (W)
; 0010: Video ADDR High (W)
; 0011: Video control (W)
; 0100: Timer Status & Control(R/W)
; 0101: PS/2 RX Data (R)
; 0110: Sound REG Index (W)
; 0111: Sound REG Data (W)
; 1000: Serial Status & Control (R/W)
; 1001: Serial Data RX/TX (R/W)
; 1010: SPI Status & Control(R/W)
; 1011: SPI Data RX/TX (R/W)
; 1100
; 1101
; 1110
; 1111: FPGA Interrupt Status Reg (R)

; VIDEO
PORTDATA	.equ	0x50
PORTADDRL	.equ	0x51
PORTADDRH	.equ	0x52
PORTMODE	.equ	0x53

; TIMER STATUS/CONTROL
PORTTIMER	.equ	0x54

; PS2 KEYBOARD
PORTKEY		.equ	0x55

; AUDIO
PORTAYADDR	.equ	0x56
PORTAYDATA	.equ	0x57

; SERIAL
PORTSERSTATUS	.equ	0x58
PORTSERCTL	.equ	0x58
PORTSERDATA	.equ	0x59

; SPI (Memory card)
PORTSPISTATUS	.equ	0x5A
PORTSPICTL	.equ	0x5A
PORTSPIDATA	.equ	0x5B

;   FPGA STATUS
PORTFPGASTATUS	.equ	0x5F

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CMD_GET_IC_VER		.equ	0x01	;Result: 1 byte in data register, version number & 0x3F

CMD_SET_BAUDRATE	.equ	0x02	;Serial port speed

;CMD_ENTER_SLEEP	.equ	0x03	;Put device into sleep mode.

;CMD_SET_USB_SPEED	.equ	0x04
	; The command sets the USB bus speed. The command requires a data input for selecting USB bus speed, corresponding to 00H
	; 12Mbps full mode, 01H at full speed corresponding to 1.5Mbps mode (non-standard mode),
	; 02H 1.5Mbps corresponding to the low speed mode. CH376 USB bus speed of 12Mbps full-speed mode by default,
	; and execution will be automatically restored to full speed 12Mbps mode after CMD_SET_USB_MODE command sets USB mode.

CMD_RESET_ALL		.equ	0x05	;Need to wait 35ms before device is ready again

CMD_CHECK_EXIST		.equ	0x06
	;Test that the interface exists and works.
	;Input: one data byte
	;Output: !input

CMD_SET_SD0_INT		.equ	0x0b	; use SPI MISO pin as INT input

;CMD_SET_RETRY		.equ	0x0b
	; Input: 0x25, setup retry times
	;  bit7=1 for infinite retry, bit3~0 retry times

CMD_GET_FILE_SIZE	.equ	0x0c
	;Input: 0x68
	;Output: file length on 4 bytes

;CMD_SET_USB_ADDRESS	.equ	0x13
	; This command sets the USB device address.
	; The command requires a data input for selecting the USB device address is operated. After a reset or a USB device is
	; connected or disconnected, the USB device address is always 00H, 00H and the
	; microcontroller through a USB device Default address communication. If the microcontroller through a
	; standard USB requests an address set up USB device, then you must also set the same USB device address by this command,
	; in order to address the new CH376 USB device communication. //Chinese doc

CMD_SET_USB_MODE	.equ	0x15
	; Switch between different USB modes.
	;	Input:
	;		00: invalid device mode (reset default)
	;		01: usb device, "peripheral firmware"
	;		02: usb device, "inner firmware"
	;		03: SD host, manage SD cards
	;		04: invalid usb host
	;		05: usb host, don't generate SOF
	;		06: usb host, generate SOF
	;		07: usb host, bus reset
	;	Output:
	;		0x51: success
	;		0x5F: failure
	;
	MODE_HOST_INV		.equ	0x04
	MODE_HOST_0		.equ	0x05
	MODE_HOST_1		.equ	0x07
	MODE_HOST_2		.equ	0x06
	MODE_HOST_SD		.equ	0x03
	MODE_DEFAULT		.equ	0x00

CMD_GET_STATUS		.equ	0x22
	; Get interrupt status after an interrupt was triggered.
	; Output: interrupt status (see below)

CMD_RD_USB_DATA0	.equ	0x27
	; Read data from interrupt port, or USB receive buffer.
	; Output: length + data

CMD_WR_USB_DATA		.equ	0x2c
	; Write data to transfer buffer
	; Input: length + data

CMD_WR_REQ_DATA		.equ	0x2d
	; Write requested data
	; Used when writing to files
	; Output (before input!): length of chunk to write
	; Input: data to fill the requested length

CMD_WR_OFS_DATA		.equ	0x2e
	; Write data to buffer with offset
	; Input: offset, length, data

CMD_SET_FILE_NAME	.equ	0x2f
	; Set file or directory name for filesystem operations
	; Input: null-terminated string
	; The command accepts at most 14 characters. File name must start with '/'.
	; Special values:
	; "": do not open anything
	; "*": list every files
	; "/": open root directory
	; "/FOO.TXT": file in root directory
	; "FOO.TXT": file in current directory

;These commands have no direct output, instead they trigger an interrupt when done running.

CMD_DISK_CONNECT	.equ	0x30
	; Wait for USB mass storage to be connected
	; Interrupt with USB_INT_SUCCESS if drive is ready.

CMD_DISK_MOUNT		.equ	0x31
	; Mount detected USB drive.
	; Triggers USB_INT_SUCCESS and returns 36 byte drive identifier in interrupt buffer.

CMD_FILE_OPEN		.equ	0x32
	; Open a file or directory.
	; Can also return ERR_MISS_FILE if the file is not found.

CMD_FILE_ENUM_GO	.equ	0x33
	; Enumerate next file
	; Used for reading directory catalog, get next FAT32 entry
	; Use CMD_SET_FILE_NAME with a pattern (eg. "/ *" to list all files in root dir).
	; Then use FILE_OPEN to get the first matching file.
	; Interrupt status will be USB_INT_DISK_READ, data will be the FAT32 directory entry
	; Then use this command to move on to the next matching file until the interrupt is ERR_MISS_FILE.

CMD_FILE_CREATE		.equ	0x34
	; Create a file (or truncate an existing file).
	; The file must be open (you will get ERR_MISS_FILE) before creating.
	; The default date is 2004/1/1 and length is 1 byte.
	; USe DIR_INFO_READ and DIR_INFO_SAVE to edit the directory entry.

CMD_FILE_ERASE		.equ	0x35
	; Delete a file.
	; Make sure the current file is closed first or it will also be deleted!
	; Use SET_FILE_NAME then CMD_FILE_ERASE

CMD_FILE_CLOSE		.equ	0x36
	; Close an open file.
	; Input: 1 to update file length, 0 to leave it unchanged

CMD_DIR_INFO_READ	.equ	0x37
	; Read directory info
	; Input one byte which is the id of the file to get info from (in the current dir). Only the first
	; 16 entries can be accessed this way!
	; Otherwise, first open the file then query for entry 0xFF. The FAT entry for the currently open
	; file will be returned.
	; The data is returned in the interrupt stream.

CMD_DIR_INFO_SAVE	.equ	0x38
	; Update directory info
	; You can modify the directory entry using WR_OFS_DATA and then write it again using this command.

CMD_BYTE_LOCATE		.equ	0x39
	; Seek to position in file
	; Input: 4 byte file offset
	; Returns USB_INT_SUCCESS with new (absolute) offset or FFFFFFFF if reached end of file.
	; Moving to FFFFFFFF actually seeks to the end of the file (to write in append mode)

CMD_BYTE_READ		.equ	0x3a
	; Read from file
	; Data is returned in chunks of 255 bytes max at a time as interrupt data, then BYTE_RD_GO must be
	; used to get next chunk (as long as the interrupt status is USB_INT_DISK_READ).
	; If the pointer becomes USB_INT_SUCCESS before the requested number of bytes has been read, it
	; means the EOF was reached.
	; Input: number of bytes to read (16 bit)

CMD_BYTE_RD_GO		.equ	0x3b
	; Get next chunk of data after BYTE_READ

CMD_BYTE_WRITE		.equ	0x3c
	; Write to file
	; Triggers interrupt USB_INT_DISK_WRITE. MCU should ask how much bytes to write using WR_REQ_DATA
	; and send the bytes. Operation is finished when the interrupt is USB_INT_SUCCESS.
	; Size in FAT will be updated when closing the file.

CMD_BYTE_WR_GO		.equ	0x3d
	; Continue write operation, after a WR_REQ_DATA if the interrupt is not INT_SUCCESS yet.

CMD_DISK_CAPACITY	.equ	0x3e
	; Get the number of sectors on disk (interrupt return, 4 bytes).

CMD_DISK_QUERY		.equ	0x3f
	; Get the info about the FAT partition via interrupt data:
	; 4 bytes: total number of sectors
	; 4 bytes: number of free sectors
	; 1 byte: partition type

CMD_DIR_CREATE		.equ	0x40
	; Create and open a directory (name must be set using SET_FILE_NAME).
	; Open an already existing directory (does not truncate)
	; Returns ERR_FOUND_NAME if the name exists but is a file
	; As with FILE_CREATE, the FAT entry can be edited (default values are the same except size is 0 and
	; directory attribute is set)

;CMD_SET_ADDRESS	.equ	0x45
	; The command is to set the USB control transfer command address. The command requires a data input,
	; a new USB device address is specified, the effective address is 00H ~ 7FH.
	; This command is used to simplify the standard USB requests SET_ADDRESS,
	; CH376 interrupt request to the MCU after the command is completed,
	; if the interrupt status is USB_INT_SUCCESS, then the command is executed successfully.//Chinese doc

;CMD_GET_DESCR		.equ	0x46
	; This command is to obtain a control transfer command descriptor. This command needs to input data specifying
	; the type of the descriptor to be acquired, effective type is 1 or 2, corresponding respectively to DEVICE device descriptors
	; CONFIGURATION configuration descriptor, wherein the configuration descriptor further includes an interface descriptor,
	; and endpoint descriptor symbol. This command is used to simplify USB request GET_DESCRIPTOR,
	; CH376 interrupt request to the microcontroller upon completion of the command, if the interrupt status is USB_INT_SUCCESS,
	; then the command is executed successfully, the device can be acquired by CMD_RD_USB_DATA0 command descriptor data.
	; Since the control of the transmission buffer CH376 only 64 bytes, when the descriptor is longer than 64 bytes,
	;  the returning operation state CH376 USB_INT_BUF_OVER, for the USB device, the device can be controlled by CMD_ISSUE_TKN_X command transmission process itself.

;CMD_SET_CONFIG		.equ	0x49
	; The command set is a control transfer instruction USB configuration. The command requires a data input,
	; to specify a new USB configuration values, configuration 0,configuration is canceled, or should the configuration descriptor from the USB device.
	; This command is used to simplify the standard USB requests SET_CONFIGURATION,CH376 interrupt request to the MCU after the command is completed,
	; if the interrupt status is USB_INT_SUCCESS, then the command is executed successfully.//Chinese doc

;CMD_AUTO_CONFIG	.equ	0x4D
	; This command is used to automatically configure the USB device does not support SD card.
	; This command is used to simplify the initialization step ordinary USB device corresponds GET_DESCR, SET_ADDRESS,
	; SET_CONFIGURATION like plurality of command sequences. CH376 After completion of the command request interrupt
	; to the microcontroller, if the interrupt status is USB_INT_SUCCESS, then the command is executed successfully.

;CMD_ISSUE_TKN_X	.equ	0x4E
	; The command used to trigger data transfers with the USB devices.
	; The second parameter tells we are performing a control transfer (0x80), on endpoint 0 (the 4 high bits).
	; An USB device has several endpoints, which are like independent communication channels.
	; Endpoint 0 is used for control transfers, specific commands to configure the device.

CMD_DISK_READ		.equ	0x54
	; Reads Logical Sector(s). Accepts 5 bytes as: 4 bytes are a Little-Endian DWORD with the starting sector and one additional byte for the quantity of Sectors.
	; Each Sector will trigger 8 interrupts to the MCU, at each the MCU must read 64 bytes (i.e., a chunk is one eigth of the 512-byte Sector). To advance to the
	; next chunk, the MCU must issue the CMD_DISK_RD_GO command (see below).

CMD_DISK_RD_GO		.equ	0x55
	; Requests the next 64-byte chunk for the requested Sector(s). While there are still chunks left, the ANSW_USB_INT_DISK_READ will be issued. Having no chunks
	; to read anymore, the ANSW_USB_INT_SUCCESS interrupted will be issued.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Answers from CH376
;
;	Interrupt status
;	================
;
;	Bit 6 of the status port is 0 when an interrupt is pending.
;	As read from command 0x22, status of interrupts (also clears the interrupt)
;	00 to 0F is for USB device mode (see CH372 docs)
;
;	0x2*, 0x3*: usb device error
;	bit 4: parity valid (if the bit is 0 data may be corrupt)
;	Low nibble:
; 		0xA: NAK
;		0xE: stalled transfer
;		xx00: timeout
;		other: PID of device
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ANSW_RET_SUCCESS	.equ	0x51		;Operation successful

ANSW_USB_INT_SUCCESS	.equ	0x14		;Operation successful, no further data
ANSW_USB_INT_CONNECT	.equ	0x15		;New USB device connected
ANSW_USB_INT_DISCONNECT	.equ	0x16		;USB device unplugged!

ANSW_USB_INT_USB_READY	.equ	0x18		;Device is ready
ANSW_USB_INT_DISK_READ	.equ	0x1d		;Disk read operation
ANSW_USB_INT_DISK_WRITE	.equ	0x1e		;Disk write operation

ANSW_RET_ABORT		.equ	0x5F		;Operation failure
ANSW_USB_INT_DISK_ERR	.equ	0x1f		;USB storage device error
ANSW_USB_INT_BUF_OVER 	.equ	0x17		;Buffer overflow
ANSW_ERR_OPEN_DIR	.equ	0x41		;Tried to open a directory with FILE_OPEN
ANSW_ERR_MISS_FILE	.equ	0x42		;File not found
ANSW_ERR_FOUND_NAME	.equ	0x43
ANSW_ERR_DISK_DISCON	.equ	0x82		;Disk disconnected
ANSW_ERR_LARGE_SECTOR	.equ	0x84		;Sector size is not 512 bytes
ANSW_ERR_TYPE_ERROR	.equ	0x92		;Invalid partition type, reformat drive
ANSW_ERR_BPB_ERROR	.equ	0xa1		;Partition not formatted
ANSW_ERR_DISK_FULL	.equ	0xb1		;Disk full
ANSW_ERR_FDT_OVER	.equ	0xb2		;Directory full
ANSW_ERR_FILE_CLOSE	.equ	0xb4		;Attempted operation on closed file

CH376_ERR_OVERFLOW	.equ	0x03
CH376_ERR_TIMEOUT	.equ	0x02
CH376_ERR_NO_RESPONSE	.equ	0x01
CH376_ERR_LONGFILENAME	.equ	0x04
;File attributes
CH376_ATTR_READ_ONLY	.equ	0x01		;read-only file
CH376_ATTR_HIDDEN	.equ	0x02		;hidden file
CH376_ATTR_SYSTEM	.equ	0x04		;system file
CH376_ATTR_VOLUME_ID	.equ	0x08		;Volume label
CH376_ATTR_DIRECTORY	.equ	0x10		;subdirectory (folder)
CH376_ATTR_ARCHIVE	.equ	0x20		;archive (normal) file


