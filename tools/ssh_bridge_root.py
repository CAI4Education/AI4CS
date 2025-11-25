#!/usr/bin/env python3
import socket
import paramiko
import threading

# TCP server settings
HOST = "127.0.0.1"
PORT = 6000   # << usa una porta diversa dal bridge dell’hacker

# SSH (root)
SSH_HOST = "127.0.0.1"
SSH_PORT = 2222
SSH_USER = "root"
SSH_PASS = "root"


def handle_client(conn):
    print("[root-bridge] Client connected.")

    # Prepara sessione SSH come root
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(
            SSH_HOST,
            SSH_PORT,
            SSH_USER,
            SSH_PASS,
            look_for_keys=False
        )
    except Exception as e:
        print("[root-bridge] SSH connection error:", e)
        conn.sendall(b"ERROR: SSH connection failed\n")
        conn.close()
        return

    # Loop: legge comandi come testo semplice
    while True:
        data = conn.recv(1024)
        if not data:
            break

        command = data.decode("utf-8", errors="ignore").strip()
        print("[root-bridge] Received:", command)

        if command.startswith("START_CHALLENGE"):
            try:
                _, challenge_name = command.split(" ", 1)
            except ValueError:
                conn.sendall(b"ERROR: Invalid format\n")
                continue

            full_cmd = f"/opt/ctf/runchallenge.sh {challenge_name}"
            print(f"[root-bridge] Executing as root: {full_cmd}")

            try:
                stdin, stdout, stderr = ssh.exec_command(full_cmd)
                out = stdout.read().decode("utf-8", errors="ignore")
                err = stderr.read().decode("utf-8", errors="ignore")

                if err:
                    msg = f"ERROR: {err}".encode()
                else:
                    msg = f"OK: Challenge {challenge_name} started\n".encode()

                conn.sendall(msg)

            except Exception as e:
                print("[root-bridge] Exec error:", e)
                conn.sendall(b"ERROR: Failed to execute command\n")

        else:
            conn.sendall(b"ERROR: Unknown command\n")

    conn.close()
    ssh.close()
    print("[root-bridge] Client disconnected.")


# Main server
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen(5)

print(f"[root-bridge] Listening on {HOST}:{PORT}")

while True:
    client, addr = server.accept()
    threading.Thread(target=handle_client, args=(client,), daemon=True).start()