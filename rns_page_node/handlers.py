"""Request handlers and response generation for rns-page-node."""

import os
import subprocess
from pathlib import Path
from typing import Any, Optional, Union

import RNS

DEFAULT_INDEX = """>Default Home Page

This node is serving pages using rns-page-node, but index.mu was not found.
Please add an index.mu file to customize the home page.
"""

DEFAULT_NOTALLOWED = """>Request Not Allowed

You are not authorised to carry out the request.
"""


def serve_default_index(
    _path: str,
    _data: Any,
    _request_id: bytes,
    _link_id: bytes,
    _remote_identity: Any,
    _requested_at: float,
) -> bytes:
    """Serve the default index page when no index.mu file exists."""
    return DEFAULT_INDEX.encode("utf-8")


def serve_page(
    path: str,
    data: Any,
    _request_id: bytes,
    _link_id: Optional[bytes],
    remote_identity: Any,
    _requested_at: float,
    pagespath: Path,
) -> bytes:
    """Serve a .mu page file, executing it as a script if it has a shebang."""
    pagespath = pagespath.resolve()
    relative_path = path[6:] if path.startswith("/page/") else path[5:]
    file_path = (pagespath / relative_path).resolve()

    if not str(file_path).startswith(str(pagespath)):
        return DEFAULT_NOTALLOWED.encode("utf-8")

    is_script = False
    file_content: Optional[bytes] = None
    try:
        with file_path.open("rb") as file_handle:
            first_line = file_handle.readline()
            is_script = first_line.startswith(b"#!")
            file_handle.seek(0)
            if not is_script:
                return file_handle.read()
            file_content = file_handle.read()
    except FileNotFoundError:
        return DEFAULT_NOTALLOWED.encode("utf-8")
    except OSError as err:
        RNS.log(f"Error reading page {file_path}: {err}", RNS.LOG_ERROR)
        return DEFAULT_NOTALLOWED.encode("utf-8")

    if is_script and os.access(str(file_path), os.X_OK):
        try:
            env_map = os.environ.copy()
            if _link_id is not None:
                env_map["link_id"] = RNS.hexrep(_link_id, delimit=False)
            if remote_identity is not None:
                env_map["remote_identity"] = RNS.hexrep(
                    remote_identity.hash,
                    delimit=False,
                )
            if data is not None and isinstance(data, dict):
                for e in data:
                    if isinstance(e, str) and (
                        e.startswith("field_") or e.startswith("var_")
                    ):
                        env_map[e] = data[e]
            result = subprocess.run(  # noqa: S603
                [str(file_path)],
                stdout=subprocess.PIPE,
                check=True,
                env=env_map,
            )
            return result.stdout
        except Exception as e:
            RNS.log(f"Error executing script page: {e}", RNS.LOG_ERROR)

    if file_content is not None:
        return file_content

    try:
        with file_path.open("rb") as file_handle:
            return file_handle.read()
    except FileNotFoundError:
        return DEFAULT_NOTALLOWED.encode("utf-8")
    except OSError as err:
        RNS.log(f"Error reading page fallback {file_path}: {err}", RNS.LOG_ERROR)
        return DEFAULT_NOTALLOWED.encode("utf-8")


def serve_file(
    path: str,
    _data: Any,
    _request_id: bytes,
    _link_id: bytes,
    _remote_identity: Any,
    _requested_at: float,
    filespath: Path,
) -> Union[bytes, list[Any]]:
    """Serve a file from the files directory."""
    filespath = filespath.resolve()
    relative_path = path[6:] if path.startswith("/file/") else path[5:]
    file_path = (filespath / relative_path).resolve()

    if not file_path.is_file() or not str(file_path).startswith(str(filespath)):
        return DEFAULT_NOTALLOWED.encode("utf-8")

    try:
        return [
            file_path.open("rb"),
            {"name": file_path.name.encode("utf-8")},
        ]
    except OSError as err:
        RNS.log(f"Error opening file {file_path}: {err}", RNS.LOG_ERROR)
        return DEFAULT_NOTALLOWED.encode("utf-8")
