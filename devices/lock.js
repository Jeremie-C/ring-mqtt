const RingSocketDevice = require('./base-socket-device')

class Lock extends RingSocketDevice {
    constructor(deviceInfo) {
        super(deviceInfo, 'alarm')
        this.deviceData.mdl = 'Lock'

        this.entity.lock = {
            component: 'lock',
            isLegacyEntity: true  // Legacy compatibility
        }
    }

    publishState() {
        var lockState
        switch(this.device.data.locked) {
            case 'locked':
                lockState = 'LOCKED'
                break;
            case 'unlocked':
                lockState = 'UNLOCKED'
                break;
            default:
                lockState = 'UNKNOWN'
        }
        this.mqttPublish(this.entity.lock.state_topic, lockState)
        this.publishAttributes()
    }

    // Process messages from MQTT command topic
    processCommand(command, message) {
        switch (command) {
            case 'lock/command':
                this.setLockState(message)
                break;
            default:
                this.debug(`Received message to unknown command topic: ${command}`)
        }
    }

    // Set lock target state on received MQTT command message
    setLockState(message) {
        this.debug(`Received set lock state ${message}`)
        const command = message.toLowerCase()
        switch(command) {
            case 'lock':
            case 'unlock':
                this.device.sendCommand(`lock.${command}`)
                break;
            default:
                this.debug('Received invalid command for lock')
        }
    }
}

module.exports = Lock