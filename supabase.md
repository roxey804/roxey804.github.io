# Supabase Setup & Schema

This file contains the SQL scripts and configuration needed to migrate the local plant database and user state to Supabase.

## SQL Schema

Run the following script in the **SQL Editor** of your Supabase dashboard to create the necessary tables and policies.

```sql
-- 1. Create the master plants table
CREATE TABLE plants (
  id TEXT PRIMARY KEY,
  common_name TEXT NOT NULL,
  latin_name TEXT,
  family TEXT,
  category TEXT NOT NULL,
  variety TEXT,
  description TEXT,
  difficulty TEXT,
  images JSONB,
  characteristics JSONB,
  schedule JSONB,
  care JSONB,
  propagation JSONB,
  deadheading JSONB,
  seed_saving JSONB,
  varieties TEXT[],
  companion_plants TEXT[],
  common_problems TEXT[],
  fun_fact TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create the wishlist table
CREATE TABLE wishlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  common_name TEXT NOT NULL,
  category TEXT,
  image_url TEXT,
  notes TEXT,
  added_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create the user profiles table (for garden state)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  state JSONB DEFAULT '{
    "selectedPlants": [],
    "completedTasks": {},
    "tracking": {},
    "welcomeShown": false
  }'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 5. Set up access policies
CREATE POLICY "Allow public read access on plants" ON plants FOR SELECT USING (true);
CREATE POLICY "Allow users to manage their own wishlist" ON wishlist FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Allow users to manage their own profile" ON user_profiles FOR ALL USING (auth.uid() = id);
```

## Setup Steps

1.  **Run SQL**: Execute the script above in Supabase.
2.  **Get Keys**: Go to **Project Settings -> API** and copy:
    *   `Project URL`
    *   `anon` public key
3.  **Local Env**: Create a `.env` file (ignored by git) to store these keys.
4.  **Migration**: Run the migration script (to be created) to upload local JSON data to the `plants` table.

## Deployment Note
Since this is a static HTML app, you can host it on **GitHub Pages**, **Vercel**, or **Netlify** for free.
