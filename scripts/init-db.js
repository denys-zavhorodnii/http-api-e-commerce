#!/usr/bin/env node

const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

// Database file path
const dbPath = path.join(__dirname, '../database/ecommerce.db');

// Create database directory if it doesn't exist
const dbDir = path.dirname(dbPath);
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

// Initialize database
const db = new sqlite3.Database(dbPath);

console.log('🗄️  Initializing E-commerce database...');

// Read and execute the initialization SQL
const initSqlPath = path.join(__dirname, '../database/init.sql');
const initSql = fs.readFileSync(initSqlPath, 'utf8');

db.exec(initSql, (err) => {
  if (err) {
    console.error('❌ Error initializing database:', err);
    process.exit(1);
  } else {
    console.log('✅ E-commerce database initialized successfully!');
    console.log('📊 Database file created at:', dbPath);
    
    // Close the database connection
    db.close((err) => {
      if (err) {
        console.error('❌ Error closing database:', err);
        process.exit(1);
      } else {
        console.log('🔒 Database connection closed');
        console.log('\n🚀 You can now start the API server with: npm run dev');
      }
    });
  }
});
