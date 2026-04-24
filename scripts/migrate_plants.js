const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');
const { globSync } = require('glob');

// --- CONFIG ---
// These should ideally be environment variables
const SUPABASE_URL = 'https://zkshgncrjuhpqnohsyoh.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_SERVICE_KEY) {
  console.error('Error: SUPABASE_SERVICE_ROLE_KEY environment variable is not set.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function migrate() {
  console.log('🚀 Starting migration...');

  const plantFiles = globSync('plants/**/*.json');
  const weedFiles = globSync('weeds/*.json');
  
  // Combine all files, excluding indexes and data.js
  const allFiles = [...plantFiles, ...weedFiles].filter(f => !f.endsWith('index.json') && !f.endsWith('data.js'));

  console.log(`Found ${allFiles.length} plant files.`);

  const plantsToUpsert = [];

  for (const file of allFiles) {
    try {
      const content = fs.readFileSync(file, 'utf8');
      const data = JSON.parse(content);

      // Map JSON to DB Schema
      const plant = {
        id: data.id,
        common_name: data.commonName,
        latin_name: data.latinName,
        family: data.family,
        category: data.category,
        variety: data.variety,
        description: data.description,
        images: data.images,
        characteristics: data.characteristics,
        schedule: data.schedule,
        care: data.care,
        propagation: data.propagation,
        deadheading: data.deadheading,
        seed_saving: data.seedSaving,
        milestones: data.milestones,
        edible: typeof data.edible === 'object' ? data.edible : { isEdible: !!data.edible },
        varieties: data.varieties || [],
        companion_plants: data.companionPlants || [],
        troubleshooting: data.troubleshooting || data.commonProblems || [],
        fun_fact: data.funFact
      };

      plantsToUpsert.push(plant);
    } catch (e) {
      console.error(`❌ Error parsing ${file}:`, e.message);
    }
  }

  if (plantsToUpsert.length > 0) {
    const { error } = await supabase
      .from('plants')
      .upsert(plantsToUpsert, { onConflict: 'id' });

    if (error) {
      console.error('❌ Error upserting plants:', error.message);
    } else {
      console.log(`✅ Successfully migrated ${plantsToUpsert.length} plants.`);
    }
  }

  console.log('🏁 Migration complete.');
}

migrate();
