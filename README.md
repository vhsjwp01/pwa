# pwa
Plummer's WiFi Automation

## What is this?
How'd you like to build your own wifi repeater for less than $200? What if told you that you could do that without gcc and dkms? You can.

## Why is this?
I'm cheap and lazy. I should say, I would rather exert myself today in the hopes that I don't have to tomorrow. Having said that, and having tinkered with openWRT for years, I had the opportunity to research, understand, and develop self healing meshes using HWMP and hostapd on the raspberry pi platform a few years ago. After that project, I stopped buying custom (and sometimes expensive) wifi routers for my home, and just started making my own. The repo exists so that I can rapidly deploy new hardware in my home based off an out-of-the box Ubuntu Server base.

## How is this?
This repo was originally based off of ubuntu 18 / debian buster and it required some additional apt sources and ppas to make things work, mostly because of firmware packages for different vendor dongle series. With the arrival of Ubuntu 22 and Raspbian 11, all of that is now unecessary. The scripts in this repo, once installed, take over networking and create a wan link via the physical ethernet port, and a bridge with the wifi interface(s) (in case one ever wants to add more radios or other interfaces for peer visibility).  Setup assumes that you ALREADY have a SEPARATE DNS/DHCP server(s), those services will not be configured by this repo, since this in intended to be an AP repeater, NOT an AP station.

## Recommended hardware
- any RALINK USB dongle
- any compute platform capable of running Ubuntu 22 or Raspbian 11 with Ralink module support
  - tested and works with:
    - Intel based boards
    - Atom based boards
    - Raspberry Pi boards
    - Libre boards
    - Odroid boards
