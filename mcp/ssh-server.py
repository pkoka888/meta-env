import os
import sys
import subprocess
import json
import paramiko
from paramiko import SSHConfig

def main():
    """
    A simple MCP server that executes commands on remote hosts via SSH.
    """
    # Get the SSH configuration from environment variables
    ssh_config_path = os.environ.get("SSH_CONFIG_PATH")
    allowed_hosts = os.environ.get("ALLOWED_HOSTS", "").split(",")

    # Read the request from stdin
    try:
        request = json.load(sys.stdin)
        host = request.get("host")
        command = request.get("command")
    except json.JSONDecodeError:
        print(json.dumps({"error": "Invalid JSON request"}), file=sys.stderr)
        sys.exit(1)

    # Validate the request
    if not host or not command:
        print(json.dumps({"error": "Missing host or command"}), file=sys.stderr)
        sys.exit(1)

    if host not in allowed_hosts:
        print(json.dumps({"error": f"Host {host} is not in the list of allowed hosts"}), file=sys.stderr)
        sys.exit(1)

    # Parse the SSH config file
    try:
        with open(ssh_config_path) as f:
            ssh_config = SSHConfig()
            ssh_config.parse(f)
    except FileNotFoundError:
        print(json.dumps({"error": f"SSH config file not found at {ssh_config_path}"}), file=sys.stderr)
        sys.exit(1)

    # Get the host configuration
    host_config = ssh_config.lookup(host)

    if not host_config:
        print(json.dumps({"error": f"Host {host} not found in SSH config file"}), file=sys.stderr)
        sys.exit(1)

    # Connect to the host
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(
            hostname=host_config.get("hostname"),
            port=host_config.get("port"),
            username=host_config.get("user"),
            password="bambilion",  # I will continue to use the password for now
        )
    except Exception as e:
        print(json.dumps({"error": str(e)}), file=sys.stderr)
        sys.exit(1)

    # Execute the command
    try:
        stdin, stdout, stderr = client.exec_command(command)
        print(json.dumps({"stdout": stdout.read().decode(), "stderr": stderr.read().decode()}))
    except Exception as e:
        print(json.dumps({"error": str(e)}), file=sys.stderr)
        sys.exit(1)
    finally:
        client.close()

if __name__ == "__main__":
    main()