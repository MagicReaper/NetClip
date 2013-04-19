//
//  Structs.h
//  NetClip
//
//  Created by Thomas Patschinski on 12.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#ifndef NetClip_Structs_h
#define NetClip_Structs_h

#define MAX_PATH 260

typedef enum {ctText = 2, ctDIB = 3, ctFile = 6} ClipoardType;

// Commands
#define CMD_QUIT					1
#define CMD_GET_TEXT				2
#define CMD_GET_DIB					3
#define CMD_GET_TIFF				4
#define CMD_GET_WAVE				5
#define CMD_SEND_FILE				6

typedef enum {
    crOK,
    crUnknownCommand,
    crFormatNotAvailable,
    crFailedOpenClip,
    crNoFileSend,
    crNoMemory,
    crFileSendCanceld,
    crFileTransferOk,
    crFileOpenError,
    crPending,
    crError,
    crTimeout
} ClipboardResult;

// Results
#define RESULT_OK					0
#define RESULT_UNKNOWNCOMMAND		1
#define RESULT_FORMATNOTAVAILABLE	2
#define RESULT_FAILEDOPENCLIP		3
#define RESULT_NOFILESEND			4
#define RESULT_NOMEMORY				5
#define RESULT_FILESENDCANCELD		6
#define RESULT_FILETRANSFEROK		7
#define RESULT_FILEOPENERROR		8


typedef struct tagNCCOMMAND {
	unsigned int	uiCommand;
	char			cFileName[MAX_PATH];
	unsigned int	uiFileLen;
	unsigned int	uiCommandVersion;
	unsigned int	uiReserved1;
	unsigned int	uiReserved2;
} NCCOMMAND, *LPNCCOMMAND;

typedef struct tagNCRESULT {
	unsigned int	uiResult;
	unsigned int	uiDataLength;
	unsigned int	uiReserved1;
	unsigned int	uiReserved2;
} NCRESULT, *LPNCRESULT;


#pragma pack(2)

typedef struct tagBITMAPFILEHEADER {
    unsigned short bfType;
    unsigned int bfSize;
    unsigned short bfReserved1;
    unsigned short bfReserved2;
    unsigned int bfOffBits;
} BITMAPFILEHEADER;

#pragma pack()

#endif
