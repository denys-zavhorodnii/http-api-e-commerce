import sqlite3 from 'sqlite3';
import path from 'path';

export interface Episode {
  id: number;
  title: string;
  episode_number: number;
  release_year: number;
  director: string;
  description: string;
  created_at: string;
}

export interface Character {
  id: number;
  name: string;
  species: string;
  homeworld: string;
  affiliation: string;
  description: string;
  created_at: string;
}

export interface CharacterAppearance {
  id: number;
  character_id: number;
  episode_id: number;
  role: string;
  screen_time_minutes: number;
  created_at: string;
}

export interface CharacterWithAppearances extends Character {
  appearances: Episode[];
}

export interface EpisodeWithCharacters extends Episode {
  characters: Character[];
}

class DatabaseManager {
  private db: sqlite3.Database;
  private dbPath: string;

  constructor() {
    this.dbPath = path.join(__dirname, '../database/starwars.db');
    this.db = new sqlite3.Database(this.dbPath);
  }

  async initialize(): Promise<void> {
    return new Promise((resolve, reject) => {
      // Read and execute the initialization SQL
      const fs = require('fs');
      const initSql = fs.readFileSync(path.join(__dirname, '../database/init.sql'), 'utf8');
      
      this.db.exec(initSql, (err) => {
        if (err) {
          console.error('Error initializing database:', err);
          reject(err);
        } else {
          console.log('✅ Database initialized successfully');
          resolve();
        }
      });
    });
  }

  async getAllEpisodes(): Promise<Episode[]> {
    return new Promise((resolve, reject) => {
      this.db.all('SELECT * FROM episodes ORDER BY episode_number', (err, rows) => {
        if (err) reject(err);
        else resolve(rows as Episode[]);
      });
    });
  }

  async getEpisodeById(id: number): Promise<Episode | null> {
    return new Promise((resolve, reject) => {
      this.db.get('SELECT * FROM episodes WHERE id = ?', [id], (err, row) => {
        if (err) reject(err);
        else resolve(row as Episode | null);
      });
    });
  }

  async getAllCharacters(): Promise<Character[]> {
    return new Promise((resolve, reject) => {
      this.db.all('SELECT * FROM characters ORDER BY name', (err, rows) => {
        if (err) reject(err);
        else resolve(rows as Character[]);
      });
    });
  }

  async getCharacterById(id: number): Promise<Character | null> {
    return new Promise((resolve, reject) => {
      this.db.get('SELECT * FROM characters WHERE id = ?', [id], (err, row) => {
        if (err) reject(err);
        else resolve(row as Character | null);
      });
    });
  }

  async getCharactersByEpisode(episodeId: number): Promise<Character[]> {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT c.* FROM characters c
        INNER JOIN character_appearances ca ON c.id = ca.character_id
        WHERE ca.episode_id = ?
        ORDER BY ca.role DESC, c.name
      `;
      
      this.db.all(query, [episodeId], (err, rows) => {
        if (err) reject(err);
        else resolve(rows as Character[]);
      });
    });
  }

  async getEpisodesByCharacter(characterId: number): Promise<Episode[]> {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT e.* FROM episodes e
        INNER JOIN character_appearances ca ON e.id = ca.episode_id
        WHERE ca.character_id = ?
        ORDER BY e.episode_number
      `;
      
      this.db.all(query, [characterId], (err, rows) => {
        if (err) reject(err);
        else resolve(rows as Episode[]);
      });
    });
  }

  async getCharacterAppearances(characterId: number): Promise<CharacterAppearance[]> {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT ca.*, e.title as episode_title, e.episode_number
        FROM character_appearances ca
        INNER JOIN episodes e ON ca.episode_id = e.id
        WHERE ca.character_id = ?
        ORDER BY e.episode_number
      `;
      
      this.db.all(query, [characterId], (err, rows) => {
        if (err) reject(err);
        else resolve(rows as CharacterAppearance[]);
      });
    });
  }

  async searchCharacters(query: string): Promise<Character[]> {
    return new Promise((resolve, reject) => {
      const searchQuery = `
        SELECT * FROM characters 
        WHERE name LIKE ? OR species LIKE ? OR homeworld LIKE ? OR affiliation LIKE ?
        ORDER BY name
      `;
      const searchTerm = `%${query}%`;
      
      this.db.all(searchQuery, [searchTerm, searchTerm, searchTerm, searchTerm], (err, rows) => {
        if (err) reject(err);
        else resolve(rows as Character[]);
      });
    });
  }

  async getCharactersByAffiliation(affiliation: string): Promise<Character[]> {
    return new Promise((resolve, reject) => {
      this.db.all('SELECT * FROM characters WHERE affiliation LIKE ? ORDER BY name', [`%${affiliation}%`], (err, rows) => {
        if (err) reject(err);
        else resolve(rows as Character[]);
      });
    });
  }

  async getEpisodeWithCharacters(episodeId: number): Promise<EpisodeWithCharacters | null> {
    const episode = await this.getEpisodeById(episodeId);
    if (!episode) return null;

    const characters = await this.getCharactersByEpisode(episodeId);
    return { ...episode, characters };
  }

  async getCharacterWithAppearances(characterId: number): Promise<CharacterWithAppearances | null> {
    const character = await this.getCharacterById(characterId);
    if (!character) return null;

    const appearances = await this.getEpisodesByCharacter(characterId);
    return { ...character, appearances };
  }

  async close(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.db.close((err) => {
        if (err) reject(err);
        else resolve();
      });
    });
  }
}

export const db = new DatabaseManager();
