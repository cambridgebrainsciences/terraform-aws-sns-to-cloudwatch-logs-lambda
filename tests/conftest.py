import os
import pytest
import socket
from moto.moto_server.threaded_moto_server import ThreadedMotoServer


@pytest.fixture(scope="session")
def fixtures_dir():
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), "fixtures")
