#!/bin/bash

OUTPUT="commands.txt"
> "$OUTPUT"

COMMANDS=(
  ls cat cp mv rm mkdir rmdir touch
  pwd cd tree file stat
  chmod chown chgrp umask
  find locate which whereis
  grep sed awk sort uniq cut tr wc
  head tail less more watch
  echo printf xargs yes
  tar gzip gunzip zcat zip unzip
  df du free uptime top ps kill killall time
  uname hostname whoami who users id groups
  ping traceroute curl wget ftp ssh scp sftp
  mount umount df
  crontab at
  env printenv set alias unalias
  clear reset history
  nano vi vim diff patch
)

for cmd in "${COMMANDS[@]}"; do
  if man "$cmd" &>/dev/null; then
    echo -e "\n\n### $cmd\n" >> "$OUTPUT"

    man "$cmd" | col -b \
    | awk '
      BEGIN { section=""; seenName=0; seenSyn=0; seenDesc=0 }

      # Sezione NAME
      /^NAME$/ {
        section="NAME"
        if(seenName==0) { print "## NAME\n"; seenName=1 }
        next
      }

      # Sezione SYNOPSIS
      /^SYNOPSIS$/ {
        section="SYNOPSIS"
        if(seenSyn==0) { print "\n## SYNOPSIS\n"; seenSyn=1 }
        next
      }

      # Sezione DESCRIPTION
      /^DESCRIPTION$/ {
        section="DESCRIPTION"
        if(seenDesc==0) { print "\n## DESCRIPTION\n"; seenDesc=1 }
        next
      }

      # Se trovi un titolo MAIUSCOLO diverso da NAME/SYNOPSIS/DESCRIPTION,
      # chiudi la sezione
      /^[A-Z][A-Z ]*$/ {
        section=""
        next
      }

      # Se siamo in una sezione valida, stampa
      section == "NAME" || section == "SYNOPSIS" || section == "DESCRIPTION" {
        print
      }
    ' >> "$OUTPUT"
  fi
done

echo "✔ Manuale generato in $OUTPUT"
