# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['CanConnect3.py'],
             pathex=['C:\\Users\\Eric Baril\\PycharmProjects\\CanConnect'],
             binaries=[],
             datas=[],
             hiddenimports=["engineio.async_drivers.gevent"],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='CanConnect3',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          icon='C:\\Users\\Eric Baril\\PycharmProjects\\CanConnect\\static\\favicon.ico',
          console=True )
