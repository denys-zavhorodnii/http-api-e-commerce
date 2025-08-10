# Fastify TypeScript HTTP API

A modern, fast HTTP API built with Fastify and TypeScript.

## Features

- ⚡ **Fastify** - High-performance web framework
- 🔷 **TypeScript** - Type-safe development
- 🛡️ **Security** - Helmet for security headers
- 🌐 **CORS** - Cross-origin resource sharing support
- 📝 **Logging** - Built-in request logging
- 🔄 **Hot Reload** - Development with nodemon
- 🗄️ **SQLite Database** - Star Wars characters and episodes data
- 🎬 **Star Wars API** - Complete character and episode management

## Prerequisites

- Node.js >= 18.0.0
- npm >= 8.0.0

## Installation

```bash
npm install
npm run init-db
```

## Development

Start the development server with hot reload:

```bash
npm run dev
```

Or with file watching:

```bash
npm run dev:watch
```

## Building

Build the project for production:

```bash
npm run build
```

## Running

Start the production server:

```bash
npm start
```

## API Endpoints

### Health & Status
- `GET /health` - Health check endpoint
- `GET /health/db` - Database health check

### Episodes
- `GET /api/episodes` - Get all episodes
- `GET /api/episodes/:id` - Get episode by ID
- `GET /api/episodes/:id/characters` - Get episode with all characters

### Characters
- `GET /api/characters` - Get all characters
- `GET /api/characters/:id` - Get character by ID
- `GET /api/characters/:id/appearances` - Get character with all episode appearances
- `GET /api/characters/search/:query` - Search characters by name, species, homeworld, or affiliation
- `GET /api/characters/affiliation/:affiliation` - Get characters by affiliation (Jedi, Sith, Rebel, etc.)

### Examples
- `GET /api/hello` - Example GET endpoint
- `POST /api/echo` - Example POST endpoint that echoes request body

## Project Structure

```
├── src/
│   ├── app.ts          # Main application file
│   └── database.ts     # Database utilities and types
├── database/
│   ├── init.sql        # Database schema and sample data
│   └── starwars.db     # SQLite database file (generated)
├── scripts/
│   └── init-db.js      # Database initialization script
├── dist/               # Compiled JavaScript (generated)
├── package.json        # Dependencies and scripts
├── tsconfig.json       # TypeScript configuration
├── nodemon.json        # Nodemon configuration
└── README.md           # This file
```

## Database Schema

The Star Wars database includes three main tables:

- **`episodes`** - Movie information (title, episode number, year, director, description)
- **`characters`** - Character details (name, species, homeworld, affiliation, description)
- **`character_appearances`** - Junction table linking characters to episodes with role and screen time

### Sample Data
- 6 episodes (Episodes I-VI from the original and prequel trilogies)
- 12 main characters (Luke, Leia, Han, Vader, Obi-Wan, Yoda, etc.)
- Character appearances across all episodes with roles and screen time

## Environment Variables

- `PORT` - Server port (default: 3000)
- `HOST` - Server host (default: 0.0.0.0)
- `NODE_ENV` - Environment (development/production)

## Scripts

- `npm run dev` - Start development server
- `npm run dev:watch` - Start development server with file watching
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm run clean` - Clean build directory
- `npm run init-db` - Initialize the Star Wars SQLite database

## License

ISC
