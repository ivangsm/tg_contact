# Stage 1: Build the application
FROM hexpm/elixir:1.17.2-erlang-27.0.1-alpine-3.20.2 AS build

# Set environment variables
ENV MIX_ENV=prod \
    LANG=C.UTF-8

# Install system dependencies
RUN apk add --no-cache build-base git

# Set up working directory
WORKDIR /app

# Copy mix files and install dependencies
COPY mix.exs mix.lock ./
COPY config ./config
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy the application source code
COPY . .

# Compile the Phoenix application
RUN mix compile

# Generate the release
RUN mix release

# Stage 2: Prepare the runtime environment
FROM alpine:3.18 AS runner

# Install necessary runtime dependencies, including C++ and GCC libraries
RUN apk add --no-cache openssl ncurses-libs libstdc++ libgcc

# Set environment variables
ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    PORT=4000 \
    HOME=/app

# Set up working directory
WORKDIR /app

# Copy the built release from the previous stage
COPY --from=build /app/_build/prod/rel/tg_contact ./

# Expose the port on which the app will run
EXPOSE 4000

# Set the default entrypoint to run the Phoenix release
CMD ["bin/tg_contact", "start"]
