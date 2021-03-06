#!/bin/bash

if [[ "$1" == "bitcoin-cli" || "$1" == "bitcoin-tx" || "$1" == "bitcoind" || "$1" == "test_bitcoin" ]]; then
	CMD="$1"
	shift
	if [[ -s "/run/secrets/btcrpcuser" ]]; then
		BTC_RPC_USER="$(cat /run/secrets/btcrpcuser)"
	fi
	if [[ -s "/run/secrets/btcrpcpassword" ]]; then
		BTC_RPC_PASSWORD="$(cat /run/secrets/btcrpcpassword)"
	fi
	if [[ ! -s "$BTC_DATA/bitcoin.conf" ]]; then
		cat <<-EOF > "/home/bitcoin/bitcoin.conf"
		printtoconsole=1
		rpcallowip=::/0
		EOF
	else
		cp "$BTC_DATA/bitcoin.conf" /home/bitcoin/bitcoin.conf
		chmod ug+rw /home/bitcoin/bitcoin.conf
	fi
	echo "rpcpassword=${BTC_RPC_PASSWORD:-$(cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c16)}" >> /home/bitcoin/bitcoin.conf
	echo "rpcuser=${BTC_RPC_USER:-$(cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c16)}" >> /home/bitcoin/bitcoin.conf
	exec "$CMD" -conf=/home/bitcoin/bitcoin.conf $@
fi

exec "$@"

