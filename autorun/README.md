# How to setup autorun

-   install plugin "Save and Run" by wk-j (wk-j.save-and-run)
-   add this to setting.json (local in `.vscode/settings.jspn` or in global config file)

```json
    "saveAndRun": {
        "commands": [
            // {
            //     "match": ".asm$",
            //     "cmd": "./autorun/run.sh ${file}",
            //     "useShortcut": false,
            //     "silent": true
            // }
            {
                "match:": "\\.asm$",
                "cmd": "./autorun/runc.sh ${fileDirname}/${fileBasenameNoExt}",
                "useShortcut": false,
                "silent": true
            }
        ]
    }
```

# How to use GDB with comfort

1. set desired command in `cmd.gdb`
2. run gdb `gdb -x cmd.gdb main`

- or you can specify comannd to run in console

```bash
gdb -ex "layout src" main
```
