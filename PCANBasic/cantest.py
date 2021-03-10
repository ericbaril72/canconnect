import can
bus = can.interface.detect_available_configs()
print(bus)