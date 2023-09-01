FROM python:3.10-bullseye
WORKDIR /app

RUN \
  pip install --no-cache-dir pysqlite3-binary || ( \
    echo "pysqlite3-binary is not available, building from source" && \
    cd /tmp && \
    wget https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release -O sqlite.tar.gz && \
    tar xzf sqlite.tar.gz && \
    cd sqlite/ && \
    ./configure && \
    make && make install && \
    cd .. && \
    git clone https://github.com/coleifer/pysqlite3.git && \
    cp sqlite/sqlite3.[ch] pysqlite3/ && \
    cd pysqlite3 && \
    python setup.py build_static build && \
    python setup.py install && \
    cd /tmp && rm -rf sqlite* pysqlite3 && \
    cd /usr/local/lib/python3.10 && \
    mv sqlite3 sqlite3.old && \
    cp -rp site-packages/pysqlite3-*/pysqlite3 sqlite3 )

COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

ENV DEBIAN_FRONTEND noninteractive

# Install package dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        alsa-utils \
        libsndfile1-dev && \
    apt-get clean

COPY . /app
RUN pip install .
ENTRYPOINT [ "python", "./main.py" ]
