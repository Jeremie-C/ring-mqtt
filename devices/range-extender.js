const RingSocketDevice = require('./base-socket-device')

class RangeExtender extends RingSocketDevice {
    constructor(deviceInfo) {
        super(deviceInfo)

        // Device data for Home Assistant device registry
        this.deviceData.mdl = 'Z-Wave Range Extender'
        this.deviceData.name = this.device.location.name + ' Range Extender'
    }

    initDiscoveryData() {
        // Device has no sensors, only publish info data
        this.initInfoDiscoveryData('acStatus')
    }

    publishData() {
        // Publish device attributes (batterylevel, tamper status)
        this.publishAttributes()
    }
}

module.exports = RangeExtender