#!/usr/bin/env python3
"""
Script to combine all 00-PLAN documents into a single organized document.
Original files remain unchanged.
"""

import os
import re
from pathlib import Path
from datetime import datetime

def get_sort_key(filename):
    """Extract sorting key from filename to maintain logical order."""
    # Extract the part after 00-PLAN-
    match = re.match(r'00-PLAN-(.+)\.md', filename)
    if not match:
        return (999, filename)
    
    key = match.group(1)
    
    # Handle numeric sections (0-9)
    if key.isdigit():
        return (int(key), key)
    
    # Handle decimal sections (0.5)
    if '.' in key:
        parts = key.split('-')
        try:
            num = float(parts[0])
            return (int(num * 10), key)
        except ValueError:
            pass
    
    # Handle C- prefix for component sections
    if key.startswith('C-'):
        component_name = key[2:]
        return (1000, component_name)
    
    return (2000, key)

def read_file_content(filepath):
    """Read content of a markdown file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return f.read()

def combine_plan_documents():
    """Combine all 00-PLAN documents into a single file."""
    plan_dir = Path(__file__).parent.parent / 'docs' / 'plan'
    output_file = plan_dir / '00-PLAN-COMBINED.md'
    
    # Get all 00-PLAN files
    plan_files = sorted(
        [f for f in plan_dir.glob('00-PLAN-*.md') if f != output_file],
        key=lambda x: get_sort_key(x.name)
    )
    
    print(f"Found {len(plan_files)} 00-PLAN documents")
    print(f"Output file: {output_file}")
    
    # Create combined document
    combined_content = []
    
    # Add header
    combined_content.append(f"# AI Command Center - Combined Plan Document")
    combined_content.append(f"\n**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    combined_content.append(f"\n**Source files:** {len(plan_files)} documents")
    combined_content.append(f"\n---")
    combined_content.append(f"\n")
    
    # Combine each file with a section header
    for filepath in plan_files:
        print(f"Processing: {filepath.name}")
        
        # Add section separator
        combined_content.append(f"\n## Source: {filepath.name}")
        combined_content.append(f"\n---")
        combined_content.append(f"\n")
        
        # Read and append file content
        content = read_file_content(filepath)
        combined_content.append(content)
        
        # Add separator between files
        combined_content.append(f"\n")
        combined_content.append(f"\n---")
        combined_content.append(f"\n")
    
    # Write combined document
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(''.join(combined_content))
    
    print(f"\n✓ Combined document created: {output_file}")
    print(f"✓ Original files unchanged")

if __name__ == '__main__':
    combine_plan_documents()
