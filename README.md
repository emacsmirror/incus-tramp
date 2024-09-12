# incus-tramp - TRAMP integration for Incus containers

`incus-tramp.el` offers an
[Emacs](https://www.gnu.org/software/emacs/)
[TRAMP](https://www.gnu.org/software/tramp/) method for
[Incus](https://linuxcontainers.org/incus/) containers.

It uses the `incus` command line tool to login to containers
and list running containers (for completion purposes).

## Usage

Offers the TRAMP method `incus` to access running containers

    C-x C-f /incus:user@container:/path/to/file

    where
      user           is the user that you want to use (optional)
      container      is the id or name of the container

---
Thanks to [*onixie*](https://github.com/onixie/lxd-tramp), author of
`lxd-tramp`, from which this project is basically a copy.

Thanks to [*montag451*](https://github.com/montag451/lxc-tramp) the
author of `lxc-tramp.el` for suggestions.
