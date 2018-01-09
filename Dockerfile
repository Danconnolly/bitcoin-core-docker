FROM debian:stretch-slim

ENV BTC_VERSION 0.15.1
ENV BTC_URL https://bitcoin.org/bin/bitcoin-core-0.15.1/bitcoin-0.15.1-x86_64-linux-gnu.tar.gz
ENV BTC_SHA256 387c2e12c67250892b0814f26a5a38f837ca8ab68c86af517f975a2a2710225b

ADD $BTC_URL /tmp/bitcoin.tar.gz
RUN cd /tmp \
	&& echo "$BTC_SHA256  bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm bitcoin.tar.gz

RUN addgroup bitcoin && adduser --gecos "" --home /home/bitcoin --disabled-password --ingroup bitcoin bitcoin
ENV BTC_DATA /data
RUN mkdir "$BTC_DATA" \
	&& chown -R bitcoin:bitcoin "$BTC_DATA" \
	&& ln -sfn "$BTC_DATA" /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /data

COPY entrypoint.sh /entrypoint.sh
USER bitcoin
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["bitcoind"]

