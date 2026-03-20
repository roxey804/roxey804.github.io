---
name: plant
description: Researches a new plant and adds it to the project. Use when the user wants to add a specific vegetable, herb, or flower to their plant diary.
---
# Plant Skill

This skill guides the process of adding a new plant to the UK Plant diary. It involves thorough research, image sourcing, and data integration.

## Workflow

1.  **Research**: Use `google_web_search` to find UK-specific growing details for the requested plant. Look for:
    *   English name, Latin name, family.
    *   Category (one of: `houseplant`, `flower`, `herb`, `fruit`, `vegetable`).
    *   Variety (e.g., 'Genovese' for Basil; leave as empty string if not found).
    *   UK-specific schedule (weeks for sowing indoors/outdoors, hardening off, planting out, harvesting).
    *   Care instructions (sowing, watering, feeding, etc.).
    *   Characteristics (height, spread, sun/water needs, container size).
    *   Propagation, deadheading, and seed saving details.
    *   Companion plants and common problems.
    *   A fun fact.
    *   *Note*: Calibrate all dates for London/South England (Last frost: Week 15, First frost: Week 44).

2.  **Image Sourcing**:
    *   Search for high-quality images of: the plant, seed, flower, fruit/pod (if applicable), and seedling.
    *   Use `run_shell_command` with `curl` to download images to `images/<plant-id>/`.
    *   Aim for `.jpg` format.
    *   *Important*: Only `fruit` and `vegetable` categories should have an `images.fruit` subcategory; others should omit it.

3.  **Data Generation**:
    *   Create a JSON file at `plants/<plant-id>.json` following the schema in `AIrequirements.md`.
    *   Update `plants/index.json` with the new ID.
    *   Regenerate `plants/data.js` by combining all plant JSON files into a single `window.PLANT_DATA` array.

4.  **Verification**:
    *   Check that the new plant appears in the "My Plants" view of the app.
    *   Verify the schedule bars in the "Timeline" view.

## Resources

-   `scripts/update_plant_data.cjs`: A script to sync JSON files into `plants/data.js`.

## UK Growing Calendar Calibration (London)

-   **Early Spring (Wks 8-12)**: Sow many seeds indoors.
-   **Last Frost (Wk 15)**: Mid-April.
-   **Late Spring (Wks 16-20)**: Harden off and start planting out half-hardy plants.
-   **Summer (Wks 21-35)**: Peak growing and harvesting.
-   **First Frost (Wk 44)**: Early November.
