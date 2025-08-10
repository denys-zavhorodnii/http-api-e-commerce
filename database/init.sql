-- Star Wars Database Schema
-- This script creates the database structure and populates it with sample data

-- Drop tables if they exist (for clean initialization)
DROP TABLE IF EXISTS character_appearances;
DROP TABLE IF EXISTS characters;
DROP TABLE IF EXISTS episodes;

-- Create episodes table
CREATE TABLE episodes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    episode_number INTEGER NOT NULL,
    release_year INTEGER NOT NULL,
    director TEXT,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create characters table
CREATE TABLE characters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    species TEXT,
    homeworld TEXT,
    affiliation TEXT, -- Jedi, Sith, Rebel, Empire, etc.
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create character_appearances table (junction table for many-to-many relationship)
CREATE TABLE character_appearances (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL,
    episode_id INTEGER NOT NULL,
    role TEXT, -- Main character, Supporting, Cameo, etc.
    screen_time_minutes INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (episode_id) REFERENCES episodes(id) ON DELETE CASCADE,
    UNIQUE(character_id, episode_id)
);

-- Insert sample episodes data
INSERT INTO episodes (title, episode_number, release_year, director, description) VALUES
('A New Hope', 4, 1977, 'George Lucas', 'Luke Skywalker joins the Rebel Alliance to fight against the evil Galactic Empire.'),
('The Empire Strikes Back', 5, 1980, 'Irvin Kershner', 'Luke trains with Jedi Master Yoda while the Empire hunts the Rebel Alliance.'),
('Return of the Jedi', 6, 1983, 'Richard Marquand', 'Luke confronts Darth Vader and the Emperor in the final battle for the galaxy.'),
('The Phantom Menace', 1, 1999, 'George Lucas', 'Jedi Knights discover a young boy with extraordinary abilities on the desert planet Tatooine.'),
('Attack of the Clones', 2, 2002, 'George Lucas', 'Anakin Skywalker begins his Jedi training while a mysterious threat emerges.'),
('Revenge of the Sith', 3, 2005, 'George Lucas', 'Anakin Skywalker falls to the dark side and becomes Darth Vader.');

-- Insert sample characters data
INSERT INTO characters (name, species, homeworld, affiliation, description) VALUES
('Luke Skywalker', 'Human', 'Tatooine', 'Jedi/Rebel', 'A young farm boy who discovers he is strong with the Force and becomes a Jedi Knight.'),
('Princess Leia Organa', 'Human', 'Alderaan', 'Rebel', 'A princess and leader of the Rebel Alliance, strong-willed and determined.'),
('Han Solo', 'Human', 'Corellia', 'Rebel', 'A smuggler and captain of the Millennium Falcon, known for his wit and piloting skills.'),
('Darth Vader', 'Human', 'Tatooine', 'Sith/Empire', 'A powerful Sith Lord and enforcer of the Galactic Empire, formerly Anakin Skywalker.'),
('Obi-Wan Kenobi', 'Human', 'Stewjon', 'Jedi', 'A wise Jedi Master who trained both Anakin and Luke Skywalker.'),
('Yoda', 'Unknown', 'Unknown', 'Jedi', 'A legendary Jedi Master, small in size but great in wisdom and power.'),
('Chewbacca', 'Wookiee', 'Kashyyyk', 'Rebel', 'A loyal Wookiee warrior and co-pilot of the Millennium Falcon.'),
('R2-D2', 'Droid', 'Naboo', 'Rebel', 'A resourceful astromech droid with a brave personality.'),
('C-3PO', 'Droid', 'Tatooine', 'Rebel', 'A protocol droid fluent in over six million forms of communication.'),
('Emperor Palpatine', 'Human', 'Naboo', 'Sith/Empire', 'The dark ruler of the Galactic Empire and master of Darth Vader.'),
('Anakin Skywalker', 'Human', 'Tatooine', 'Jedi', 'A young Jedi Knight with great potential who falls to the dark side.'),
('Padmé Amidala', 'Human', 'Naboo', 'Republic', 'A queen and senator of Naboo, mother of Luke and Leia.');

-- Insert character appearances data
INSERT INTO character_appearances (character_id, episode_id, role, screen_time_minutes) VALUES
-- Episode 4: A New Hope
(1, 1, 'Main Character', 45), -- Luke
(2, 1, 'Main Character', 35), -- Leia
(3, 1, 'Main Character', 40), -- Han
(4, 1, 'Main Character', 25), -- Vader
(5, 1, 'Main Character', 30), -- Obi-Wan
(6, 1, 'Supporting', 15), -- Yoda (mentioned)
(7, 1, 'Supporting', 20), -- Chewbacca
(8, 1, 'Supporting', 25), -- R2-D2
(9, 1, 'Supporting', 20), -- C-3PO

-- Episode 5: The Empire Strikes Back
(1, 2, 'Main Character', 50), -- Luke
(2, 2, 'Main Character', 30), -- Leia
(3, 2, 'Main Character', 35), -- Han
(4, 2, 'Main Character', 20), -- Vader
(5, 2, 'Supporting', 10), -- Obi-Wan (force ghost)
(6, 2, 'Main Character', 25), -- Yoda
(7, 2, 'Supporting', 20), -- Chewbacca
(8, 2, 'Supporting', 20), -- R2-D2
(9, 2, 'Supporting', 15), -- C-3PO

-- Episode 6: Return of the Jedi
(1, 3, 'Main Character', 55), -- Luke
(2, 3, 'Main Character', 35), -- Leia
(3, 3, 'Main Character', 30), -- Han
(4, 3, 'Main Character', 25), -- Vader
(5, 3, 'Supporting', 5), -- Obi-Wan (force ghost)
(6, 3, 'Supporting', 10), -- Yoda (force ghost)
(7, 3, 'Supporting', 20), -- Chewbacca
(8, 3, 'Supporting', 20), -- R2-D2
(9, 3, 'Supporting', 15), -- C-3PO
(10, 3, 'Main Character', 20), -- Emperor

-- Episode 1: The Phantom Menace
(11, 4, 'Main Character', 40), -- Anakin
(12, 4, 'Main Character', 35), -- Padmé
(5, 4, 'Main Character', 45), -- Obi-Wan
(10, 4, 'Supporting', 15), -- Palpatine
(8, 4, 'Supporting', 20), -- R2-D2
(9, 4, 'Supporting', 15), -- C-3PO

-- Episode 2: Attack of the Clones
(11, 5, 'Main Character', 50), -- Anakin
(12, 5, 'Main Character', 40), -- Padmé
(5, 5, 'Main Character', 45), -- Obi-Wan
(10, 5, 'Supporting', 20), -- Palpatine
(8, 5, 'Supporting', 20), -- R2-D2
(9, 5, 'Supporting', 15), -- C-3PO

-- Episode 3: Revenge of the Sith
(11, 6, 'Main Character', 55), -- Anakin
(12, 6, 'Main Character', 30), -- Padmé
(5, 6, 'Main Character', 40), -- Obi-Wan
(10, 6, 'Main Character', 25), -- Palpatine
(8, 6, 'Supporting', 20), -- R2-D2
(9, 6, 'Supporting', 15); -- C-3PO

-- Create indexes for better performance
CREATE INDEX idx_character_appearances_character_id ON character_appearances(character_id);
CREATE INDEX idx_character_appearances_episode_id ON character_appearances(episode_id);
CREATE INDEX idx_characters_name ON characters(name);
CREATE INDEX idx_episodes_title ON episodes(title);
CREATE INDEX idx_episodes_episode_number ON episodes(episode_number);
