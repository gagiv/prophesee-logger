# prophesee-logger

A TypeScript logging library that wraps [pino](https://github.com/pinojs/pino) and its ecosystem to provide a unified logging solution for Node.js services.

## Overview

`prophesee-logger` bundles together the most commonly needed pieces of the pino stack so consumers get structured logging, HTTP request logging, pretty-printed development output, and rotating file transports from a single dependency.

## Built on

- **[pino](https://github.com/pinojs/pino)** — fast, low-overhead structured JSON logger (core)
- **[pino-http](https://github.com/pinojs/pino-http)** — HTTP request/response logging middleware
- **[pino-pretty](https://github.com/pinojs/pino-pretty)** — human-readable output for local development
- **[pino-roll](https://github.com/mcollina/pino-roll)** — time/size-based log file rotation

## Requirements

- Node.js **>= 20**
- TypeScript **>= 5.4** (for consumers writing TypeScript)

## Installation

```bash
npm install prophesee-logger
```

## Development

Clone the repo and install dependencies:

```bash
npm install
```

### Scripts

| Script | Description |
| --- | --- |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm run dev` | Compile in watch mode |
| `npm run clean` | Remove the `dist/` output directory |

### Project layout

```
prophesee-logger/
├── src/          # TypeScript sources
│   └── index.ts  # Library entry point
├── dist/         # Compiled output (generated)
├── package.json
└── tsconfig.json
```

## License

TBD
