import Fastify, { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import { db } from './database';

const server: FastifyInstance = Fastify({
  logger: true,
  trustProxy: true,
});

// Register plugins
server.register(cors, {
  origin: true,
  credentials: true,
});

server.register(helmet, {
  contentSecurityPolicy: false,
});

// Health check route
server.get('/health', async (request, reply) => {
  return { status: 'ok', timestamp: new Date().toISOString() };
});

// Database health check
server.get('/health/db', async (request, reply) => {
  try {
    const episodes = await db.getAllEpisodes();
    return { 
      status: 'ok', 
      database: 'connected',
      episodes_count: episodes.length,
      timestamp: new Date().toISOString() 
    };
  } catch (error) {
    reply.status(500);
    return { 
      status: 'error', 
      database: 'disconnected',
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString() 
    };
  }
});

// Star Wars API Routes

// Get all episodes
server.get('/api/episodes', async (request, reply) => {
  try {
    const episodes = await db.getAllEpisodes();
    return { episodes, count: episodes.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch episodes', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get episode by ID
server.get('/api/episodes/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const episodeId = parseInt(id);
    
    if (isNaN(episodeId)) {
      reply.status(400);
      return { error: 'Invalid episode ID' };
    }

    const episode = await db.getEpisodeById(episodeId);
    if (!episode) {
      reply.status(404);
      return { error: 'Episode not found' };
    }

    return episode;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch episode', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get episode with characters
server.get('/api/episodes/:id/characters', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const episodeId = parseInt(id);
    
    if (isNaN(episodeId)) {
      reply.status(400);
      return { error: 'Invalid episode ID' };
    }

    const episodeWithChars = await db.getEpisodeWithCharacters(episodeId);
    if (!episodeWithChars) {
      reply.status(404);
      return { error: 'Episode not found' };
    }

    return episodeWithChars;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch episode with characters', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get all characters
server.get('/api/characters', async (request, reply) => {
  try {
    const characters = await db.getAllCharacters();
    return { characters, count: characters.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch characters', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get character by ID
server.get('/api/characters/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const characterId = parseInt(id);
    
    if (isNaN(characterId)) {
      reply.status(400);
      return { error: 'Invalid character ID' };
    }

    const character = await db.getCharacterById(characterId);
    if (!character) {
      reply.status(404);
      return { error: 'Character not found' };
    }

    return character;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch character', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get character with appearances
server.get('/api/characters/:id/appearances', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const characterId = parseInt(id);
    
    if (isNaN(characterId)) {
      reply.status(400);
      return { error: 'Invalid character ID' };
    }

    const characterWithApps = await db.getCharacterWithAppearances(characterId);
    if (!characterWithApps) {
      reply.status(404);
      return { error: 'Character not found' };
    }

    return characterWithApps;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch character with appearances', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Search characters
server.get('/api/characters/search/:query', async (request, reply) => {
  try {
    const { query } = request.params as { query: string };
    
    if (!query || query.trim().length < 2) {
      reply.status(400);
      return { error: 'Search query must be at least 2 characters long' };
    }

    const characters = await db.searchCharacters(query.trim());
    return { characters, count: characters.length, query: query.trim() };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to search characters', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get characters by affiliation
server.get('/api/characters/affiliation/:affiliation', async (request, reply) => {
  try {
    const { affiliation } = request.params as { affiliation: string };
    
    if (!affiliation) {
      reply.status(400);
      return { error: 'Affiliation parameter is required' };
    }

    const characters = await db.getCharactersByAffiliation(affiliation);
    return { characters, count: characters.length, affiliation };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch characters by affiliation', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Example API route
server.get('/api/hello', async (request, reply) => {
  return { message: 'Hello from Star Wars API!', timestamp: new Date().toISOString() };
});

// Example POST route
server.post('/api/echo', async (request, reply) => {
  return { 
    message: 'Echo response', 
    data: request.body,
    timestamp: new Date().toISOString() 
  };
});

// Start server
const start = async () => {
  try {
    // Initialize database
    await db.initialize();
    
    const port = process.env.PORT || 3000;
    const host = process.env.HOST || '0.0.0.0';
    
    await server.listen({ port: Number(port), host });
    
    console.log(`🚀 Star Wars API Server is running on http://${host}:${port}`);
    console.log(`📊 Health check: http://${host}:${port}/health`);
    console.log(`🗄️  Database health: http://${host}:${port}/health/db`);
    console.log(`🎬 Episodes: http://${host}:${port}/api/episodes`);
    console.log(`👥 Characters: http://${host}:${port}/api/characters`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start();
