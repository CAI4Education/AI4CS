#!/usr/bin/env python3
import socket
import paramiko
import threading
import time
import struct

HOST = "127.0.0.1"
PORT = 5000

SSH_HOST = "127.0.0.1"
SSH_PORT = 2222
SSH_USER = "root"
SSH_PASS = "root"

TERM_WIDTH = 80
TERM_HEIGHT = 24
TERM_TYPE = 'vt100'


def handle_client(client_socket):
    print("[+] TCP client connected")

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(SSH_HOST, SSH_PORT, SSH_USER, SSH_PASS, look_for_keys=False)
    except Exception as e:
        print("[bridge] SSH connect error:", e)
        client_socket.close()
        return

    chan = ssh.invoke_shell(term=TERM_TYPE, width=TERM_WIDTH, height=TERM_HEIGHT)
    chan.settimeout(0.1)

    # DISABILITA L’ECHO NEL TERMINALE REMOTO
    chan.send("stty -echo\r")
	
    stop_event = threading.Event()

    # THREAD: SSH -> TCP (forward output to Godot)
    def ssh_to_tcp():
        while not stop_event.is_set():
            try:
                if chan.recv_ready():
                    data = chan.recv(4096)
                    if data:
                        # forward raw bytes to client
                        try:
                            client_socket.sendall(data)
                        except Exception as e:
                            print("[bridge] error sending to tcp:", e)
                            break
                else:
                    time.sleep(0.01)
            except Exception as e:
                if not stop_event.is_set():
                    print("[bridge] ssh->tcp error:", e)
                break

    t = threading.Thread(target=ssh_to_tcp, daemon=True)
    t.start()

    # Buffering for incoming TCP data (Godot) — to handle length-prefixed chunks
    recv_buffer = b""

    try:
        while True:
            try:
                client_socket.settimeout(0.1)
                chunk = client_socket.recv(4096)
            except socket.timeout:
                continue
            except Exception as e:
                print("[bridge] client recv error:", e)
                break

            if not chunk:
                # connection closed by client
                break

            # Debug show raw bytes (helpful)
            print("[bridge] recv from godot (repr):", repr(chunk))

            # Append to buffer and try to extract full messages
            recv_buffer += chunk

            # The protocol coming from Godot here appears to be:
            # [4-byte little-endian length][payload bytes]
            # There may be multiple messages concatenated or fragmented.
            while True:
                if len(recv_buffer) < 4:
                    # not enough bytes to read length
                    break

                # peek 4-byte length (little-endian)
                msg_len = struct.unpack_from("<I", recv_buffer, 0)[0]

                # If msg_len is unrealistic (e.g. huge), fall back to send all as-is:
                if msg_len > 10_000_000:
                    # suspicious length -> send entire buffer raw and clear
                    try:
                        text_all = recv_buffer.decode("utf-8", errors="ignore")
                        chan.send(text_all)
                    except Exception as e:
                        print("[bridge] error sending huge raw:", e)
                    recv_buffer = b""
                    break

                # If we don't yet have the entire message, wait for more bytes
                if len(recv_buffer) < 4 + msg_len:
                    break

                # Extract payload
                payload = recv_buffer[4:4 + msg_len]
                # Remove consumed bytes from buffer
                recv_buffer = recv_buffer[4 + msg_len:]

                # payload is bytes; decode to str for Paramiko channel (keeps control chars)
                try:
                    text = payload.decode("utf-8", errors="ignore")
                except Exception:
                    # fallback: decode latin1 to preserve bytes
                    text = payload.decode("latin-1", errors="ignore")

                # Debug show what we forward
                print("[bridge] forwarding to ssh (repr):", repr(text))

                try:
                    # send to channel (Paramiko will emulate PTY)
                    chan.send(text)
                except Exception as e:
                    print("[bridge] error sending to ssh:", e)
                    stop_event.set()
                    break

            # end while parsing messages

    finally:
        stop_event.set()
        try:
            chan.close()
        except:
            pass
        try:
            ssh.close()
        except:
            pass
        try:
            client_socket.close()
        except:
            pass
        print("[-] client disconnected")


# Main server loop
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen(5)
print("[bridge] listening on", HOST, PORT)

while True:
    client_socket, addr = server.accept()
    print("[bridge] incoming from", addr)
    threading.Thread(target=handle_client, args=(client_socket,), daemon=True).start()
