# Roksana's Planting Scheduler - Gemini CLI Mandates

This project is a UK-specific planting scheduler (London focus). It uses a single-page HTML app that dynamically loads plant data from JSON files.

## Project Structure

- `index.html`: The main application.
- `plants/`: Contains individual `<plant-id>.json` files for each plant.
- `plants/data.js`: A central JS file that aggregates all plant data into `window.PLANT_DATA`. **Do not edit manually.**
- `plants/index.json`: A list of all plant IDs.
- `images/<plant-id>/`: Contains images (plant, seed, flower, fruit, seedling) for each plant.

## Gemini Skills

### `plant` Skill
Used to research and add new plants to the project.
- **Trigger**: "plant <name>" or "add <name> to my plants".
- **Workflow**:
  1. Research plant details (Latin name, UK schedule, care, etc.).
  2. Download images to `images/<plant-id>/`.
  3. Create `plants/<plant-id>.json`.
  4. Run `.gemini/skills/plant/scripts/update_plant_data.cjs` to sync all data.

## Development Workflow

1. **Adding a Plant**: Use the `plant` skill.
2. **Updating Data**: If you manually modify a JSON file in `plants/`, run `node .gemini/skills/plant/scripts/update_plant_data.cjs` to update the app's central data file.
3. **Location Calibration**: All scheduling must be calibrated for London/South East UK (Last frost: Week 15, First frost: Week 44).

## Implementation Rules

- No build tools or frameworks.
- Tailwind CSS via CDN.
- Vanilla JavaScript for the data layer.
- Ensure all images have `.jpg` extensions where possible.
