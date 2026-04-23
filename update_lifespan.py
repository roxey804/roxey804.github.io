import json
import os
import re

def update_lifespan(lifespan):
    # Fix double-updated cases if any
    lifespan = lifespan.replace("Perennial (comes back every year) (comes back every year)", "Perennial (comes back every year)")
    
    ls_lower = lifespan.lower()
    
    # Rule 4: contains "biennial" (takes precedence)
    if 'biennial' in ls_lower:
        if lifespan == "Biennial (flowers in second year)":
            return lifespan
        return "Biennial (flowers in second year)"
    
    # Rule 1 & 6: "Annual" or "Annual (grown as)"
    if ls_lower == "annual" or ls_lower == "annual (grown as)":
        return "Annual (collect seeds)"
    if lifespan == "Annual (collect seeds)":
        return lifespan
    
    # Rule 5: "Short-lived perennial" (on its own)
    if ls_lower == "short-lived perennial":
        return "Perennial (comes back every year) (short-lived)"
    if lifespan == "Perennial (comes back every year) (short-lived)":
        return lifespan
        
    # Rule 2: Exactly "Perennial"
    if ls_lower == "perennial":
        return "Perennial (comes back every year)"
    if lifespan == "Perennial (comes back every year)":
        return lifespan
        
    # Rule 3: contains "perennial" and other info
    if "perennial" in ls_lower:
        # If already has the new string, don't add it again
        if "(comes back every year)" in lifespan:
            # Handle "Annual / Perennial (comes back every year) (short-lived)" case specifically if needed
            if "annual /" in ls_lower and "short-lived" in ls_lower:
                 return "Annual / Perennial (comes back every year) (short-lived)"
            return lifespan
            
        if ls_lower == "annual / short-lived perennial":
            return "Annual / Perennial (comes back every year) (short-lived)"
        
        if "short-lived" in ls_lower:
            new_val = re.sub(r'(?i)short-lived perennial', 'Perennial (comes back every year) (short-lived)', lifespan)
            return new_val
            
        # General case for Rule 3: replace "Perennial" with "Perennial (comes back every year)"
        new_val = re.sub(r'(?i)perennial', 'Perennial (comes back every year)', lifespan)
        return new_val

    return lifespan

def process_data(data):
    modified = False
    if isinstance(data, dict):
        for key, value in data.items():
            if key == 'lifespan' and isinstance(value, str):
                new_val = update_lifespan(value)
                if new_val != value:
                    data[key] = new_val
                    modified = True
            else:
                if process_data(value):
                    modified = True
    elif isinstance(data, list):
        for item in data:
            if process_data(item):
                modified = True
    return modified

def process_file(file_path):
    with open(file_path, 'r') as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            return

    if process_data(data):
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
            f.write('\n')
        print(f"Updated {file_path}")

directories = ['plants', 'weeds', 'wishlist']
for root_dir in directories:
    if not os.path.exists(root_dir):
        continue
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.json'):
                process_file(os.path.join(root, file))
