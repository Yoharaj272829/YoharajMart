# Build and run YoharajMart in one Debian image so runtime libraries
# from the Drogon, libcurl, and PostgreSQL packages remain available.
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        g++ \
        pkg-config \
        libdrogon-dev \
        libcurl4-openssl-dev \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only the files required to compile and serve the app.
COPY CMakeLists.txt main.cc yoharajmart.html ./

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --config Release --parallel 2

# Run as a non-root user.
RUN useradd --system --uid 10001 --create-home app \
    && chown -R app:app /app

USER app

ENV PORT=8080
EXPOSE 8080

CMD ["/app/build/YoharajMart"]
