# Data-driven app

## Installation

Install Docker for Mac from here - https://docs.docker.com/docker-for-mac/

Install Docker for Windows from here - https://docs.docker.com/docker-for-windows/

## Setup

Edit your host file and add the following line

| O.S           | Location                                          |
| ------------- |:-------------------------------------------------:|
| OSX           | /etc/host                                         |
| Windows       | C:\Windows\System32\drivers\etc\hosts             |
| Ubuntu        | Create /etc/NetworkManager/dnsmasq.d/hosts.conf   |
|               | and put aline address=/docker.localhost/localhost |
|               | in it, then restart [NetworkManager](http://serverfault.com/questions/118378/in-my-etc-hosts-file-on-linux-osx-how-do-i-do-a-wildcard-subdomain) |

```bash
$ *.docker.localhost localhost
```

Execute the following commands:

```bash
$ make build
$ make run
```

Now browse to http://data-driven.docker.localhost

### Destroy
```bash
$ make destroy
```

### Rebuild

In order to rebuild the application:

```
$ make rebuild
```

