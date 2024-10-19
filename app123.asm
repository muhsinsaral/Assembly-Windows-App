;---------------------------------------------------------------------------------------------------------
; Hello, Windows! in x86 ASM - (c) 2024 Dave's Garage - Use at your own risk no warrantly!
;---------------------------------------------------------------------------------------------------------

; Compiler directives and includes

.386						; Full 80386 instruction set and mode
.model flat, stdcall				; All 32-bit and later apps are flat. Used to include "tiny, etc"
option casemap:none				; Preserve the case of system identifiers but not our own, more or le

; Include files - headers and libs that we need for calling the system dlls like user32, gdi32, kernel32, etc

include C:\masm32\include\windows.inc		; Main windows header file
include C:\masm32\include\user32.inc		; Windows, controls, etc
include C:\masm32\include\kernel32.inc		; Handles, modules, paths, etc
include C:\masm32\include\gdi32.inc 		; Drawing into a device context (ie: painting)

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\gdi32.lib

; Forward declerations -Our main entry point  will call forward  to WinMain, so we need to define it here, etc

Winmain proto :DWORD, :DWORD, :DWORD, :DWORD	; Forward decl for MainEntry

WindowWidth	equ 640				; How big we'd like our main window
WindowHeight	equ 480

.DATA

ClassName	db "MyWinClass",0
AppName		db "Muhsin's Tiny App",0

.DATA?						; Uninitialized data - Basically just reserves address space

hInstance	HINSTANCE ?
CommandLine	LPSTR ?				; Pointer to the command line text we were launched with

;------------------------------------------------------------------------------------------------
.CODE						; Here is where the program itself lives
;------------------------------------------------------------------------------------------------

MainEntry:
	
	push NULL				; Get the instance handle of our app (NULL means ourselves)
	call GetModuleHandle			; GetModuleHandle will return instance handle in eax, etc
	mov hInstance, eax			; Cache it in our global variable

	call GetCommandLine			; Get the command line text ptr in EAX to pass on to main
	mov CommandLine, eax

	; Call our WinMain and then exit the process with whatever comes back from it
	
	push SW_SHOWDEFAULT
	lea eax, CommandLine
	push eax
	push NULL
	push hInstance
	call WinMain

	push eax
	call ExitProcess
	
;
; WinMain - The traditional signature for the main entry point of a Windows program
;

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
	
	LOCAL	wc:WNDCLASSEX			; Create these vars on the stack, hence LOCAL
	LOCAL	msg:MSG
	LOCAL	hwnd:HWND
	
	mov	wc.cbSize, SIZEOF WNDCLASSEX	; Fill in the values in the members of our windowclass
	mov	wc.style, CS_HREDRAW or CS_VREDRAW
	mov	wc.lpfnWndProc, OFFSET WndProc
	mov	wc.cbClsExtra, 0
	mov	wc.cbWndExtra, 0
	mov	eax, hInstance
	mov	wc.hInstance, eax
	mov	wc.hbrBackground, COLOR_3DSHADOW+1
	mov	wc.lpszMenuName, NULL
	mov	wc.lpszClassName, OFFSET ClassName
	
	push	IDI_APPLICATION
	push	NULL
	call	LoadIcon
	mov	wc.hIcon, eax
	mov	wc.hIconSm, eax

	push	IDC_ARROW
	push	NULL
	call	LoadCursor
	mov	wc.hCursor, eax

	lea	eax, wc
	push	eax
	call	RegisterClassEx

	push	NULL
	push	hInstance
	push	NULL
	push	NULL
	push	WindowHeight
	push	WindowWidth
	push	CW_USEDEFAULT
	push	CW_USEDEFAULT
	push	WS_OVERLAPPEDWINDOW + WS_VISIBLE
	push	OFFSET AppName
	push	OFFSET ClassName
	push	0
	call	CreateWindowExA
	cmp	eax, NULL
	je	WinMainRet
	mov	hwnd, eax
	
	push	eax
	call	UpdateWindow

MessageLoop:
	
	push	0
	push	0
	push	NULL
	lea	eax, msg
	push	eax
	call	GetMessage

	cmp	eax, 0
	je	DoneMessages

	lea	eax, msg
	push	eax
	call	TranslateMessage

	lea	eax, msg
	push	eax
	call	DispatchMessage

	jmp	MessageLoop

DoneMessages:
	
	mov	eax, msg.wParam

WinMainRet:
	
	ret

WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	hdc:HDC

	cmp	uMsg, WM_DESTROY
	jne	NotWMDestroy

	push	NULL
	call	PostQuitMessage
	xor	eax, eax
	ret

NotWMDestroy:
	cmp	uMsg, WM_PAINT
	jne	NotWMPaint

	lea	eax, ps
	push	eax
	push	hWnd
	call	BeginPaint
	mov	hdc, eax

	push	TRANSPARENT
	push	hdc
	call	SetBkMode

	lea	eax, rect
	push	eax
	push	hWnd
	call	GetClientRect

	push	DT_SINGLELINE + DT_CENTER + DT_VCENTER
	lea	eax, rect
	push	eax
	push	-1
	push	OFFSET AppName
	push	hdc
	call	DrawText

	lea 	eax, ps
	push 	eax
	push	hWnd
	call	EndPaint

	xor	eax, eax
	ret

NotWMPaint:

	push	lParam
	push	wParam
	push	uMsg
	push	hWnd
	call	DefWindowProc
	ret

WndProc endp

END MainEntry
