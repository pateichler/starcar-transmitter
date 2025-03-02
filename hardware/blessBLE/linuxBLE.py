"""
Example for a BLE 4.0 Server
"""
import logging
import asyncio
import random

from typing import Any

from bless import (  # type: ignore
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions,
)

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(name=__name__)
trigger = asyncio.Event()


def read_request(characteristic: BlessGATTCharacteristic, **kwargs) -> bytearray:
    return random.randint(0, 1000).to_bytes(4, byteorder='big')


def write_request(characteristic: BlessGATTCharacteristic, value: Any, **kwargs):
    logger.debug(f"Char value set to {value}")

    if value == b"\x0f":
        logger.debug("ENDING Stream")
        trigger.set()


async def run(loop):
    trigger.clear()

    server = BlessServer(name="Strain Gauge", loop=loop)
    server.read_request_func = read_request
    server.write_request_func = write_request
    
    my_service_uuid = "A07498CA-AD9B-475E-950D-16F1FBE7E8CD"
    await server.add_new_service(my_service_uuid)

    my_char_uuid = "51FF12BB-3ED8-46E5-B4F9-D64E2FEC021B"
    char_flags = (
        GATTCharacteristicProperties.read
        | GATTCharacteristicProperties.write
        | GATTCharacteristicProperties.indicate
    )
    
    permissions = GATTAttributePermissions.readable | GATTAttributePermissions.writeable
    await server.add_new_characteristic(
        my_service_uuid, my_char_uuid, char_flags, None, permissions
    )
    
    await server.start()
    
    await trigger.wait()

    logger.debug("Stopping server")
    await asyncio.sleep(1)
    await server.stop()


loop = asyncio.get_event_loop()
loop.run_until_complete(run(loop))
