#!/usr/bin/env python3

import json

def main():
    with open("instance_ip_0.txt", "r") as f:
        ip_address = f.read().strip()

    inventory = {
        "master": {
            "hosts": ["instance"],
            "vars": {
                "ansible_host": ip_address,
                "ansible_user": "ubuntu",
                "ansible_ssh_private_key_file": "myKey.pem"
            }
        }
    }

    print(json.dumps(inventory))

if __name__ == "__main__":
    main()
