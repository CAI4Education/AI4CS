#!/bin/bash

# File flag
echo "fl4g{chm0d_15_p0w3rfu1}" > secret_flag
echo "fake_flag" > fake_flag

# Rimuove permessi di lettura all’utente
chmod 000 secret_flag

