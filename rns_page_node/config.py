"""Configuration loading logic for rns-page-node."""

import RNS


def load_config(config_file: str) -> dict[str, str]:
    """Load configuration from a plain text config file.

    Config format is simple key=value pairs, one per line.
    Lines starting with # are comments and are ignored.
    Empty lines are ignored.

    Args:
        config_file: Path to the config file

    Returns:
        Dictionary of configuration values

    """
    config: dict[str, str] = {}
    try:
        with open(config_file, encoding="utf-8") as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" not in line:
                    RNS.log(
                        f"Invalid config line {line_num} in {config_file}: {line}",
                        RNS.LOG_WARNING,
                    )
                    continue
                key, value = line.split("=", 1)
                key = key.strip()
                value = value.strip()
                if key and value:
                    config[key] = value
        RNS.log(f"Loaded configuration from {config_file}", RNS.LOG_INFO)
    except FileNotFoundError:
        RNS.log(f"Config file not found: {config_file}", RNS.LOG_ERROR)
    except Exception as e:
        RNS.log(f"Error reading config file {config_file}: {e}", RNS.LOG_ERROR)
    return config
