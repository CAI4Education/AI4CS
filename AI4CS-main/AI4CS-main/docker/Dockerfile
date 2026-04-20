FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# Pacchetti base + SSH
# =========================
RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        sudo \
        bash && \
    mkdir /var/run/sshd && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# =========================
# Root login (solo locale / dev)
# =========================
RUN echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# =========================
# Utente hacker (solo esecuzione)
# =========================
RUN groupadd -g 1000 hacker && \
    useradd -m -u 1000 -g 1000 -s /bin/bash hacker && \
    echo "hacker:hacker" | chpasswd

# Ambiente di login completo (fondamentale)
RUN touch /home/hacker/.bashrc /home/hacker/.profile && \
    chown hacker:hacker /home/hacker/.bashrc /home/hacker/.profile

# =========================
# Struttura CTF (ROOT owner)
# =========================
RUN mkdir -p /opt/ctf/challenges && \
    mkdir -p /home/hacker/ctf_workspace

# Copia file CTF
COPY files/run_challenge.sh /opt/ctf/run_challenge.sh
COPY files/challenges/ /opt/ctf/challenges/

# Fix line endings (Windows -> Unix)
RUN sed -i 's/\r$//' /opt/ctf/run_challenge.sh && \
    sed -i 's/\r$//' /opt/ctf/challenges/*.sh

# =========================
# Permessi (CRITICO)
# =========================
# Root possiede tutto
RUN chown -R root:root /opt/ctf && \
    chmod 755 /opt/ctf && \
    chmod 755 /opt/ctf/challenges && \
    chmod 755 /opt/ctf/run_challenge.sh && \
    chmod 755 /opt/ctf/challenges/*.sh

# Hacker può lavorare SOLO nel suo workspace
RUN chown -R hacker:hacker /home/hacker/ctf_workspace && \
    chmod 755 /home/hacker && \
    chmod 700 /home/hacker/ctf_workspace

# =========================
# SSH
# =========================
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]