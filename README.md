# internet-usage-demo
Tracks wifi &amp; cellular data usage

This project intends to track/monitor data usage in iOS devices.
As there is no good way to get information of wifi/cellular network data usage since particular date-time. I'm trying to implement such a module that can calculate data usage precisely.

Currently it supports tracking data usage of all of the sessions even after device reboots (which is lacking by default APIs that resets every-time device reboots).

Background monitoring isn't implemented. But if the demo app is opened immediately before rebooting iOS device, the current session's data usage is saved and carried over to next boot-up.
