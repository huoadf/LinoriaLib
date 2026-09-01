import os

try:
    proxy = open('MatchaUIProxy.lua', 'r', encoding='utf-8').read()
    input_mgr = open('MatchaInputManager.lua', 'r', encoding='utf-8').read()
    library = open('Library.lua', 'r', encoding='utf-8').read()

    bundled = library.replace(
        'local MatchaUIProxy = loadfile("MatchaUIProxy.lua")()',
        'local MatchaUIProxy = (function()\n' + proxy + '\nend)()'
    ).replace(
        'local MatchaInputManager = loadfile("MatchaInputManager.lua")()',
        'local MatchaInputManager = (function()\n' + input_mgr + '\nend)()'
    )

    with open('BundledLibrary.lua', 'w', encoding='utf-8') as f:
        f.write(bundled)
        
    print("Successfully bundled!")
except Exception as e:
    print("Error:", e)
