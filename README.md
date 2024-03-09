
# Cool SA:MP Stuff
Ini adalah sumber terbuka untuk tutorial SA:MP, di dalam kode ini mengandung bahasa jaksel karena aku males buat terjemahin semua bahasanya ke bahasa indonesia.

## Instalasi Pemakaian

Instalasinya sendiri sih cukup mudah, kalau gamau ribet ya download aja .pwn nya yang kalian mau, misal mau download yang [01-login-register.pwn](scripts/01-login-register.pwn) ya download aja.

Atau kalau mau pakai boilerplatenya tinggal download aja reponya, terus di download manual [plugins](server/plugins/README.md)nya, jangan lupa download YSI dan omp-stdlib serta qawnonya ya!

Kalau gamau ribet, bisa langsung pakai perintah ini:
```c
git clone https://github.com/tsssu/Cool-Stuff.git
git submodule init --update --recursive
```

Tapi tetep download plugins dan server nya secara manual ya!

## Setup compiler
Buat kalian yang download boilerplate ini ya harus setup compiler manual yah dengan cara download Pawn Compiler [disini](https://github.com/pawn-lang/compiler) atau [disini](https://github.com/openmultiplayer/open.mp), terus nanti .exe nya taruh dimana kek misal kayak aku taruhnya di:
```
C:\Program Files (x86)\Pawn Compiler
```

Terus nanti tinggal taruh di PATH biar nanti penggunaannya bisa tinggal `pawncc` aja.... nanti kalau udah kalian tinggal buat `.vscode` atau setup pawn-build di Sublime Text deh (terserah ya).

### Konfigurasi .vscode versi aku
<details>
    <summary>Untuk yang pakai PowerShell.exe</summary>
	
Masukkan config ini kedalam `.vscode/tasks.json` ya!
 
```json
{
  "version": "2.0.0",
  "tasks": [
	{
	  "label": "build-normal",
	  "type": "shell",
	  "command": "pawncc",
	  "args": [
		"${file}", 
		"--%", 
		"-o${workspaceRoot}/server/gamemodes/output.amx",
		"-i${workspaceRoot}/libraries/legacy-include",
		"-i${workspaceRoot}/libraries/omp-stdlib",
		"-i${workspaceRoot}/libraries/YSI-Includes",
		"-i${workspaceRoot}/libraries/YSI-Includes/amx",
		"-i${workspaceRoot}/libraries/YSI-Includes/code-parse",
		"-i${workspaceRoot}/libraries/YSI-Includes/indirection",
		"-i${workspaceRoot}/libraries/YSI-Includes/md-sort",
		"-;+", 
		"-(+", 
		"-d3"
	  ],
	  "group": {
		"kind": "build",
		"isDefault": true
	  },
	  "isBackground": false,
	  "presentation": {
		"reveal": "silent",
		"panel": "dedicated"
	  },
	  "problemMatcher": "$pawncc"
	}
  ]
}
```
</details>

<details>
	<summary>Kalau yang vscode nya pakai cmd.exe</summary>
	
Masukkan config ini kedalam `.vscode/tasks.json` ya!

```json
{
  "version": "2.0.0",
  "tasks": [
	{
	  "label": "build-normal",
	  "type": "shell",
	  "command": "pawncc",
	  "args": [
		"${file}", 
		"-o${workspaceRoot}/server/gamemodes/output.amx",
		"-i${workspaceRoot}/libraries/legacy-include",
		"-i${workspaceRoot}/libraries/omp-stdlib",
		"-i${workspaceRoot}/libraries/YSI-Includes",
		"-i${workspaceRoot}/libraries/YSI-Includes/amx",
		"-i${workspaceRoot}/libraries/YSI-Includes/code-parse",
		"-i${workspaceRoot}/libraries/YSI-Includes/indirection",
		"-i${workspaceRoot}/libraries/YSI-Includes/md-sort",
		"-;+", 
		"-(+", 
		"-d3"
	  ],
	  "group": {
		"kind": "build",
		"isDefault": true
	  },
	  "isBackground": false,
	  "presentation": {
		"reveal": "silent",
		"panel": "dedicated"
	  },
	  "problemMatcher": "$pawncc"
	}
  ]
}
```
</details>

### Konfigurasi Pawn.sublime-build versi aku.

Untuk sublime build kayaknya agak ga mungkin kalau ga ngasih
path buat ke compiler nya, jadi ya ini dia:

<details>
	<summary>Config Pawn.sublime-build</summary>
	
Masukkan config ini kedalam `%AppData%\Sublime Text\Packages\User` ya!

```json
{
	"working_dir": "C:/Program Files (x86)/Pawn Compiler", 
	"selector": "source.pwn", 
	"cmd": [
		"pawncc.exe", 
		"$file", 
		"-o$file_path/../server/gamemodes/$file_base_name.amx",
		"-i$file_path/../libraries/omp-stdlib",
		"-i$file_path/../libraries/legacy-include",
		"-i$file_path/../libraries/YSI-Includes",
		"-i$file_path/../libraries/YSI-Includes/amx",
		"-i$file_path/../libraries/YSI-Includes/indirection",
		"-i$file_path/../libraries/YSI-Includes/code-parse",
		"-i$file_path/../libraries/YSI-Includes/md-sort",
		"-;+", 
		"-(+", 
		"-d3"
	], 
	"file_regex": "(.*?)\\(([0-9]*)[- 0-9]*\\)"
}
```
</details>
