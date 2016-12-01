MyNewt BLE App for iOS
==================

This project is an example of how to connect an iOS device to a BLE device running [Mynewt](http://mynewt.apache.org) and
the nimBLE BLE Stack.

It is a fork from the [SwiftSensorTag](https://github.com/anasimtiaz/SwiftSensorTag) application, but has been modified
for the Mynewt project.

## Configuration 

No specific configuration changes to this app should be required in order to connect with a Mynewt BLE Peripheral 
device. Mynewt BLE peripheral devices will need to conform t e following conventions in order to be recognized
by this app:

* Mynewt BLE Peripheral device name **must** start with `nimble`
* Mynewt BLE Peripheral **must** advertise any data services under the UUID `E761D2AF-1C15-4FA7-AF80-B5729020B340`
* Any sensor or other data **must** use 2 Characteristic IDs for sensor data as follows:
    * Characteristic starting with `0xDE` as a 'configuration' UUID. This UUID should be readable, and should provide a text-string representation of the Sensor sending data. (for example, `0xDEFF` "Temperature Data")
    * Characteristic UUID starting with `0xAD` as a 'data' UUID. This UUID should be subscribable and should provide updated data from the sensor itself as a single value. (for example `0xADFF` would send data for the "Temperature Data" sensor referencing `0xDEFF`

## Issues and Contributions

For any issues or bug reports please use GitHub Issues or submit pull requests for contributions.


## Contact

* Contact me at [davidgs@dragonflyiot.com](mailto:davidgs@dragonflyiot.com)
* Website: [https://davidgs.com/](https://davidgs.com/)

## License

&copy; Syed Anas Imtiaz | 2015 | MIT License – [http://opensource.org/licenses/MIT](http://opensource.org/licenses/MIT)

