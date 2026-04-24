-- 0. Custom ENUM Types
CREATE TYPE plant_category AS ENUM ('herb', 'vegetable', 'fruit', 'flower', 'houseplant', 'weed');
CREATE TYPE tracker_location AS ENUM ('indoors', 'outdoors');

-- 1. Master Plants Table (Shared/Read-Only for users)
CREATE TABLE plants (
  id TEXT PRIMARY KEY, -- slug e.g. 'basil'
  common_name TEXT NOT NULL,
  latin_name TEXT,
  family TEXT,
  category plant_category NOT NULL,
  variety TEXT,
  description TEXT,
  images JSONB,
  characteristics JSONB,
  schedule JSONB,
  care JSONB,
  propagation JSONB,
  deadheading JSONB, -- Can be boolean or object { "required": true, "info": "..." }
  seed_saving JSONB,
  milestones JSONB,
  edible JSONB, -- Can be boolean or object { "isEdible": true, "info": "..." }
  varieties TEXT[],
  companion_plants TEXT[], -- Array of strings. Can be plant IDs for linking or plain text.
  troubleshooting TEXT[], -- Maps to 'troubleshooting' in JSON
  fun_fact TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. User Profiles (Extension of auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT, -- Stored here for easy access, though also in auth.users
  display_name TEXT,
  location_name TEXT DEFAULT 'London, UK',
  welcome_shown BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Gardens (Containers for user plant selections)
CREATE TABLE gardens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL, -- e.g. 'Front Balcony'
  description TEXT,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. User Plants (Specific instances of plants in a garden)
CREATE TABLE user_plants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  garden_id UUID REFERENCES gardens(id) ON DELETE CASCADE NOT NULL,
  plant_id TEXT REFERENCES plants(id) NOT NULL,
  is_growing BOOLEAN DEFAULT true,
  custom_notes TEXT,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(garden_id, plant_id)
);

-- 5. Planting Tracker (Logs for a specific user plant)
CREATE TABLE planting_tracker (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_plant_id UUID REFERENCES user_plants(id) ON DELETE CASCADE NOT NULL,
  batch_no INTEGER DEFAULT 1,
  year INTEGER,
  location tracker_location,
  covered BOOLEAN DEFAULT false,
  date_planted TEXT, -- ddmmyy
  date_sprouted TEXT,
  date_true_leaves TEXT,
  date_first_flower TEXT,
  date_first_fruit TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Wishlist (User-level, not specific to a garden)
CREATE TABLE wishlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  common_name TEXT NOT NULL,
  category plant_category,
  image_url TEXT,
  notes TEXT,
  added_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Enable Row Level Security (RLS)
ALTER TABLE plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE gardens ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE planting_tracker ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist ENABLE ROW LEVEL SECURITY;

-- 8. Policies

-- Plants: Anyone can read
CREATE POLICY "Public plants are viewable by everyone" ON plants FOR SELECT USING (true);

-- Profiles: Users manage their own
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Gardens: Users manage their own
CREATE POLICY "Users can manage their own gardens" ON gardens FOR ALL USING (auth.uid() = user_id);

-- User Plants: Accessible if the user owns the parent garden
CREATE POLICY "Users can manage plants in their gardens" ON user_plants FOR ALL 
  USING (EXISTS (SELECT 1 FROM gardens WHERE gardens.id = user_plants.garden_id AND gardens.user_id = auth.uid()));

-- Tracker: Accessible if the user owns the parent user_plant
CREATE POLICY "Users can manage tracker for their plants" ON planting_tracker FOR ALL 
  USING (EXISTS (
    SELECT 1 FROM user_plants 
    JOIN gardens ON user_plants.garden_id = gardens.id 
    WHERE user_plants.id = planting_tracker.user_plant_id AND gardens.user_id = auth.uid()
  ));

-- Wishlist: Users manage their own
CREATE POLICY "Users can manage their own wishlist" ON wishlist FOR ALL USING (auth.uid() = user_id);

-- 9. Trigger for profile creation on sign-up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
