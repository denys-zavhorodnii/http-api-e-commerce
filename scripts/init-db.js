#!/usr/bin/env node

const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

const dbPath = path.join(__dirname, '../database/starwars.db');
const initSqlPath = path.join(__dirname, '../database/init.sql');

console.log('🗄️  Initializing Star Wars SQLite database...');
console.log(`📁 Database path: ${dbPath}`);
console.log(`📝 SQL script: ${initSqlPath}`);

// Create database directory if it doesn't exist
const dbDir = path.dirname(dbPath);
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
  console.log(`✅ Created database directory: ${dbDir}`);
}

// Create new database connection
const db = new sqlite3.Database(dbPath);

// Read the initialization SQL
const initSql = fs.readFileSync(initSqlPath, 'utf8');

console.log('📖 Reading SQL initialization script...');

// Execute the SQL script
db.exec(initSql, (err) => {
  if (err) {
    console.error('❌ Error initializing database:', err);
    process.exit(1);
  } else {
    console.log('✅ Database initialized successfully!');
    console.log('🎬 Star Wars database is ready with:');
    console.log('   - 6 episodes (Episodes I-VI)');
    console.log('   - 12 characters');
    console.log('   - Character appearances and relationships');
    
    // Test a simple query
    db.get('SELECT COUNT(*) as episode_count FROM episodes', (err, row) => {
      if (err) {
        console.error('❌ Error testing database:', err);
      } else {
        console.log(`   - Database contains ${row.episode_count} episodes`);
      }
      
      db.close((err) => {
        if (err) {
          console.error('❌ Error closing database:', err);
        } else {
          console.log('🔒 Database connection closed');
          console.log('🚀 You can now start the API server with: npm run dev');
        }
      });
    });
  }
});
