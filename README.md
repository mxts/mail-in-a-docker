# Mail-in-a-Docker

Mail-in-a-Docker (MIAD) helps you run Mail-in-a-Box (MIAB) in a docker container, making it easy to run other services on your box that won't break when you update MIAB. The aim is to make it suitable for production use.

## Why use MIAB?

None of the mail server alternatives include the very tedious work of synchronizing DNS records.

## Requirements

- MIAB v68 https://github.com/mail-in-a-box/mailinabox
- SNIProxy https://github.com/dlundquist/sniproxy
- BIND9 aka named
- NSD
- Official Docker (not snap etc)
- Ubuntu Jammy (22.04)

These will be configured as part of `create.sh`

## To do/known issues

This is still in beta, thus not recommend for production use yet

- MIAB DNS changes will not reflect until `setup-dns.sh` is executed, planning to use `inotifywait` to achieve
- Versioning, like to follow MIAB

## Installation in 1 step

This will get you up and running, but I recommend you still read through the [details](#details)

```
git clone https://github.com/mxts/mail-in-a-docker
cd mail-in-a-docker
./setup-dns.sh
./setup-sniproxy.sh
./setup-official-docker.sh # this command can damage your existing setup
./create.sh
```

## <a name="details"></a>Installation in multiple steps

### Clone this repository on the host

```BASH
git clone https://github.com/mxts/mail-in-a-docker
cd mail-in-a-docker
```

### Host install of BIND9 + NSD

```BASH
./setup-dns.sh
ping google.com
```

After `setup-dns.sh` completes, ping an internet hostname, e.g. google.com to verify it can be resolved and reach the internet

### Host install of HTTP/S proxy

In order to co-exists with other HTTP servers, MIAD uses 810 for HTTP, 4413 for HTTPS and SNIProxy to inspect packets for its requested hostname and route them to the configured server with MIAD as the fallback. Feel free to use an alternative if you know how to set that up.

```BASH
./setup-sniproxy.sh
```

After `setup-sniproxy.sh` completes, see `/etc/sniproxy.conf` on your host for more info.

### Host install of MIAD

Please ensure you are running the official docker by running `setup-official-docker.sh`. It is a short script which removes all other known installations. Docker installed via snap will not work as it has limited access to the host OS.

```BASH
./setup-official-docker.sh # this command can damage your existing setup
./create.sh
```

## Other scripts

| Command                    | Description                                                                 |
| -------------------------- | --------------------------------------------------------------------------- |
| `connect.sh`               | Connects into MIAD container's bash                                         |
| `restart.sh`               | Stop and start the MIAD container                                           |
| `rm.sh`                    | Removes the MIAD container and image                                        |
| `create.sh`                | Up the MIAD container, install and run MIAB                                 |
| `setup-dns.sh`             | Installs NSD and BIND9 on the host                                          |
| `setup-official-docker.sh` | Installs the official docker and removes the unofficial ones                |
| `setup-sniproxy.sh`        | Installs SNIProxy on the host                                               |
| `status.sh`                | Checks that all ports in the MIAD container have listeners                  |
| `data/before-install.sh`   | Optional script that runs before installing MIAB                            |
| `data/after-install.sh`    | Optional script that runs after MIAB is installed, before it starts running |

## Scope of support

I'm limiting my support to only the listed requirements, anything else, you will have to be on your own for now.
If you manage to run MIAD on something else and wish to contribute back, file a PR (which will probaby end in a branch).

## Contributing and Development

Mail-in-a-Docker is an open source project. Contributions and pull requests are welcomed, but subjected to rejection.
If in doubt, please open an issue first to clarify before committing your time and effort.

I'm using the style guide below, and it is important to follow

```JSON
"[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
}
```

- VSCode defaults
  - Dockerfile
  - Python
  - Shellscript
  - YAML

## Acknowledgements

This project would not be possible without MIAB and its contributors.
