.dotfiles
===============

Installation
-------------

Create symbolic links in the `$HOME` directory:

```console
dotfiles$ sh ./dotfiles.sh setup
```

Or, specify the dirname of the dotfiles under the `./rc` directory

```console
dotfiles$ sh ./dotfiles.sh setup home
```

Commands
----------------

- deploy
  - create symbolic links in the `$HOME` directory
- setup
  - check existing files before doing `deploy`
- clean
  - remove the symbolic links
- ls
  - list symbolic links to be created
- import
  - add a file to this dotfiles

<!--EOF-->