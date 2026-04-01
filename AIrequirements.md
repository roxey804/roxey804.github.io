# UK Planting Scheduler - Region Southeast, London

## Context

The user lives in London with and is a beginner gardener. They want a planting chart that tells them exactly what to do and when — planting seeds, expected germination time, minimum germination temperature, hardening off, planting out, soil type, approx time to fruit and harvesting.

## Approach: HTML App + Plant Data Files + `/plant` Command

The app is a single `index.html` that loads plant data from individual JSON files. Plants are added over time using a `/plant` Claude Code command, which researches the plant, finds images, and generates a rich profile. The app reads all plant files at load time and renders the scheduler + plant encyclopedia.

**No build tools, no framework, no server.** Opens directly in a browser. Mobile and laptop friendly.

## Data Model

### Plant Profiles (Rich Encyclopedia Entries)

Each plant is stored as an individual JSON file in `plants/` and rendered both in the scheduler and as a detailed profile page. Plants are added over time via the `/plant` command.

**Starting set (12 plants, all container-friendly, beginner-appropriate):**
- **Vegetables (3):** tumbing tomatoes, broad beans, courgettes
- **Herbs (6):** Basil, parsley, coriander, chives, rocket, mint
- **Flowers (3):** Nasturtiums, marigolds, snapdragons

**Each plant JSON file contains:**

```json
{
  "id": "tomato-bush",
  "commonName": "Bush Tomato",
  "latinName": "Solanum lycopersicum",
  "family": "Solanaceae",
  "category": "vegetable",
  "description": "Compact bush varieties perfect for pots on a balcony...",

  "images": {
    "plant": "images/tomato-bush/plant.jpg",
    "seed": "images/tomato-bush/seed.jpg",
    "flower": "images/tomato-bush/flower.jpg",
    "fruit": "images/tomato-bush/fruit.jpg",
    "seedling": "images/tomato-bush/seedling.jpg"
  },

  "characteristics": {
    "matureHeight": "30-60cm",
    "matureSpread": "30-45cm",
    "hardiness": "Half-hardy (not frost tolerant)",
    "lifespan": "Annual",
    "sunRequirement": "Full sun (6+ hours)",
    "waterNeeds": "Regular — containers dry out fast",
    "soilType": "Rich, well-drained potting compost",
    "containerSize": "10L+ pot"
  },

  "schedule": {
    "sowIndoorsWeeks": [8, 9, 10, 11, 12],
    "hardenOffWeeks": [18, 19, 20],
    "plantOutWeeks": [20, 21, 22, 23],
    "harvestWeeks": [28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38],
    "bringInsideWeek": 40,
    "floweringWeeks": [22, 23, 24, 25, 26, 27, 28, 29, 30],
    "firstFlowerDate": "150626",
    "frostSensitive": true
  },

  "care": {
    "sowIndoors": "Sow seeds 1cm deep in small pots on a warm windowsill (18-21°C). Keep soil moist but not waterlogged.",
    "hardenOff": "Move pots outside during the day, bring in at night. Do this for 7-10 days before planting out.",
    "plantOut": "Move to final large pot (at least 10L). Place in sunniest spot on balcony.",
    "watering": "Water daily in hot weather. Containers dry out fast. Water at the base, not the leaves.",
    "feeding": "Feed weekly with tomato fertiliser once flowers appear.",
    "harvest": "Pick when fully coloured. Regular picking encourages more fruit.",
    "overwintering": "Annual — compost the plant after the last harvest."
  },

  "propagation": {
    "fromSeed": true,
    "seedDescription": "Small, flat, pale yellow seeds. Viable for 4-5 years if stored cool and dry.",
    "germinationDays": "7-14 days at 18-21°C",
    "fromCuttings": true,
    "cuttingsMethod": "Side shoots (suckers) can be rooted in water or compost. Remove when 10cm long.",
    "fromDivision": false
  },

  "deadheading": {
    "required": false,
    "notes": "No deadheading needed. Remove yellow/diseased leaves. Pinch out side shoots on cordon types only (not bush types)."
  },

  "seedSaving": {
    "canSaveSeeds": true,
    "method": "Let a fruit fully ripen on the vine, scoop out seeds, ferment in water for 2-3 days, rinse and dry.",
    "seedPodDescription": "Seeds are inside the fruit itself."
  },

  "varieties": ["Tumbling Tom", "Totem", "Balconi Red", "Micro Tom", "Hundreds and Thousands"],
  "companionPlants": ["basil", "marigolds", "chives"],
  "commonProblems": ["Blight (keep leaves dry)", "Blossom end rot (inconsistent watering)", "Aphids (spray with diluted washing up liquid)"],
  "funFact": "Tomatoes were once considered poisonous in Europe and were grown purely as ornamental plants until the 18th century."
}
```

### Location: London, UK
- Last frost: approximately week 14-15 (early-mid April)
- First frost: approximately week 44 (early November)
- All schedule data calibrated for London/South England climate

### 8 Color-Coded Task Types
Sow Indoors (amber), Sow Outdoors (green), Harden Off (blue), Plant Out (emerald), Harvest (red), Maintain (purple), Protect (slate), Sow Again (lime)

## Three UI Views

### 1. This Week (default)
- Large week heading with date range
- Prev/next week navigation
- Task cards grouped by type, each with: plant emoji + name, color-coded badge, 2-3 sentence instruction, checkbox (persisted to localStorage), expandable "learn more"
- "Late start" banner when starting mid-season with adjusted recommendations
- Empty state with countdown to next task

### 2. Timeline (Gantt chart)
- CSS Grid horizontal scrollable chart
- Y-axis: plant names grouped by category
- X-axis: weeks 1-52 with month labels
- Color-coded bars spanning week ranges per task type
- Vertical "today" marker line
- Sticky left column, touch-friendly scrolling
- Tap bar for detail popover

### 3. My Plants (selection + plant encyclopedia)
- Card grid (3 cols desktop, 2 mobile)
- Each card shows: plant image, common name, Latin name (italic), category tag
- Toggle plants on/off (filters scheduler views)
- Category filter pills: All / Vegetables / Herbs / Flowers
- Selections persisted to localStorage
- **Tap a card → full Plant Profile page** (see below)

### 4. Plant Profile (detail page per plant)
A rich, scroll-friendly profile for each plant with sections:
- **Hero:** Large plant image, common name, Latin name (italic), family
- **Image gallery:** Thumbnails for plant, seed, flower, fruit/pod, seedling (tappable to enlarge)
- **At a Glance:** Icon grid showing height, spread, sun, water, container size, lifespan
- **Growing Calendar:** Mini Gantt bar for this plant only (sow → harvest)
- **How to Grow:** Step-by-step care instructions (sow, harden off, plant out, water, feed, harvest)
- **Propagation:** Seeds, cuttings, division — what works and how
- **Deadheading:** Whether needed, how to do it
- **Seed Saving:** How to collect and store seeds, seed pod/fruit description
- **Companion Plants:** What grows well alongside
- **Common Problems:** Pests, diseases, and fixes
- **Fun Fact:** One interesting tidbit
- Back button returns to My Plants grid

## `/plant` Command — Add New Plants Over Time

A Claude Code command at `.claude/commands/plant.md` that lets you say `/plant lavender` (or any plant name) and it:

1. **Researches the plant** — uses web search to find UK-specific growing details: Latin name, family, hardiness, schedule, care, propagation, deadheading, seed saving, varieties, companion plants, common problems
2. **Generates the plant JSON** — creates `plants/<plant-id>.json` with the full profile schema (see Data Model above). Note: Images must be added manually by the user to `images/<plant-id>/`.
3. **Updates the app** — the `index.html` auto-discovers all JSON files in `plants/` at load time, so no code changes needed
4. **Shows a summary** — confirms what was added with a preview of the key details

**Usage:** `/plant rosemary`, `/plant sunflower`, `/plant strawberry alpine`

**The command prompt will:**
- Accept one or more plant names as arguments
- Research each plant thoroughly via web search (RHS, BBC Gardeners' World, etc.)
- Determine if it's suitable for UK balcony containers (warn if not, suggest alternatives)
- Generate all schedule week numbers for UK growing
- Write the complete JSON profile
- This builds up the plant index incrementally — the app grows with each `/plant` invocation

## Header (persistent)
- App name with leaf icon
- Current date + week number
- Location: London, UK (hardcoded — user's location)
- Season progress indicator

## Implementation Steps

### Phase A: Foundation

1. **Create `/plant` command** (`.claude/commands/plant.md`) — The command that researches a plant via web search, downloads images, and generates the full JSON profile. This is the engine that populates the app.

2. **Create `index.html` scaffold** — HTML5 boilerplate, Tailwind CDN, viewport meta, custom earthy color palette, layout (header, tab bar, content area). Loads all `plants/*.json` files dynamically.

3. **Build data layer** (~300 lines JS) — Plant loader (fetch all JSON from `plants/`), `TASK_TYPES`, location config (London), `AppState` object, localStorage for completed tasks + plant selections, helper functions (`getCurrentWeek`, `getTasksForWeek`)

### Phase B: Views

4. **"This Week" view** (~200 lines) — Task cards grouped by type, week navigation, checkboxes, expandable beginner-friendly details, late-start banner for mid-season starts, empty states

5. **"Timeline" view** (~250 lines) — CSS Grid Gantt chart, sticky plant name column, horizontal scroll, color-coded bars, "today" marker, tap-to-detail

6. **"My Plants" view** (~150 lines) — Plant card grid with images, common + Latin names, category filters, selection toggles, tap-through to profile

7. **Plant Profile view** (~250 lines) — Full detail page: hero image, image gallery, characteristics grid, mini growing calendar, care instructions, propagation, deadheading, seed saving, varieties, companion plants, problems, fun fact

### Phase C: Polish

8. **Beginner help** (~80 lines) — Glossary tooltips (harden off, succession sowing, potting on, etc.), first-visit welcome

9. **Responsive + polish** (~100 lines) — Mobile breakpoints, dark mode, print stylesheet, transitions, inline favicon

### Phase D: Populate

10. **Run `/plant` for initial 24 plants** — Use the command to generate all starter plant profiles with images. This validates the command works and populates the app with data.

11. **README.md** — How to open the app, how to add new plants with `/plant`, data sources

## Visual Design
- **Palette:** Forest green (#2d6a4f), leaf green (#52b788), terracotta (#f4a261), cream (#fefae0)
- **Typography:** System font stack, 16px base, 18px on mobile task cards
- **Style:** Rounded corners, subtle shadows, generous spacing, plant emojis as visual anchors

## File Structure

```
roksanas-plants/
├── index.html                          # The app — loads plant JSON dynamically
├── README.md                           # Usage instructions
├── .claude/
│   └── commands/
│       └── plant.md                    # /plant command — add new plants via research
├── plants/                             # One JSON file per plant (added via /plant command)
│   ├── tomato-bush.json
│   ├── basil.json
│   ├── lavender.json
│   └── ... (grows over time)
└── images/                             # Plant images (added via /plant command)
    ├── tomato-bush/
    │   ├── plant.jpg
    │   ├── seed.jpg
    │   ├── flower.jpg
    │   └── seedling.jpg
    ├── basil/
    │   └── ...
    └── ...
```

**Key files to create:**
- `/Users/hiten/workspace/roksanas-plants/index.html` — The app (HTML + Tailwind + JS)
- `/Users/hiten/workspace/roksanas-plants/.claude/commands/plant.md` — The `/plant` command
- `/Users/hiten/workspace/roksanas-plants/plants/*.json` — Initial 24 plant profiles (generated via `/plant`)
- `/Users/hiten/workspace/roksanas-plants/images/*/` — Plant images (downloaded via `/plant`)

## Verification
1. Run `/plant tomato bush` — verify it creates `plants/tomato-bush.json` with full profile and downloads images to `images/tomato-bush/`
2. Open `index.html` in browser — should load with "This Week" view showing current week's tasks
3. Navigate weeks forward/backward — verify tasks change appropriately
4. Switch to Timeline view — verify Gantt chart renders with today marker
5. Switch to My Plants — verify plant cards show images, common + Latin names
6. Tap a plant card — verify full Plant Profile page renders with all sections (images, care, propagation, deadheading, seed saving, etc.)
7. Toggle plants on/off — verify they disappear from scheduler views
8. Check task completion persists after page reload (localStorage)
9. Test on mobile viewport (375px width) — all views readable and tappable
10. Run `/plant strawberry alpine` — verify a new plant appears in the app without any code changes
