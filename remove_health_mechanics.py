import os
import re

# Directory containing the timeline files
timeline_dir = r"c:\Users\abdul\Documents\GODOT PROJECT\Enigma\dialogic\timelines\qte"

# Function to remove health mechanics from a file


def remove_health_mechanics(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Remove all health-related lines
        # Remove lines that set interview_health to a specific value
        content = re.sub(r'^set \{interview_health\} = .*$',
                         '', content, flags=re.MULTILINE)

        # Remove lines that modify interview_health
        content = re.sub(
            r'^\s*set \{interview_health\} [+\-]= .*$', '', content, flags=re.MULTILINE)

        # Clean up empty lines
        content = re.sub(r'\n\n+', '\n\n', content)
        content = content.strip()

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"Updated: {os.path.basename(file_path)}")
        return True
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False


# Process all .dtl files in the directory
if os.path.exists(timeline_dir):
    for filename in os.listdir(timeline_dir):
        if filename.endswith('.dtl'):
            file_path = os.path.join(timeline_dir, filename)
            remove_health_mechanics(file_path)
    print("Health mechanics removal completed!")
else:
    print(f"Directory not found: {timeline_dir}")
